#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import PointCloud2
import numpy as np

# Helpers to convert PointCloud2 <-> numpy structured arrays
# (tiny inline versions; works for standard fields including 'time'/'t')
dtype_cache = {}

def fields_dtype(msg):
    key = tuple((f.name, f.offset, f.datatype, f.count) for f in msg.fields)
    if key in dtype_cache:
        return dtype_cache[key]
    import sensor_msgs_py.point_cloud2 as pc2
    dtype = pc2._get_struct_fmt(msg.fields, msg.point_step)
    dtype_cache[key] = dtype
    return dtype

def cloud_to_array(msg):
    import sensor_msgs_py.point_cloud2 as pc2
    return np.frombuffer(bytes(msg.data), dtype=fields_dtype(msg))

def array_to_cloud(arr, template_msg):
    out = PointCloud2()
    out.header = template_msg.header
    out.height  = template_msg.height
    out.width   = template_msg.width
    out.fields  = template_msg.fields
    out.is_bigendian = template_msg.is_bigendian
    out.point_step   = template_msg.point_step
    out.row_step     = template_msg.row_step
    out.is_dense     = template_msg.is_dense
    out.data = arr.tobytes()
    return out

class CloudTimeFix(Node):
    def __init__(self):
        super().__init__('cloud_time_fix')
        in_topic  = self.declare_parameter('in_topic',  '/velodyne_points').get_parameter_value().string_value
        out_topic = self.declare_parameter('out_topic', '/velodyne_points_cart').get_parameter_value().string_value
        self.get_logger().info(f"Subscribing: {in_topic}  → Publishing: {out_topic}")
        self.pub = self.create_publisher(PointCloud2, out_topic, 10)
        self.sub = self.create_subscription(PointCloud2, in_topic, self.cb, 10)

    def cb(self, msg: PointCloud2):
        try:
            arr = cloud_to_array(msg).copy()
            names = arr.dtype.names or ()
            # Find a per-point time field (common names: 'time', 't')
            time_field = None
            for cand in ('time', 't'):
                if cand in names:
                    time_field = cand
                    break
            if time_field:
                n = len(arr)
                # Make times strictly increasing from 0 to (n-1)*1e-6 (1 µs steps)
                # or simply zero them out; both avoid "jumps backwards".
                arr[time_field] = np.linspace(0.0, (n-1)*1e-6, n, dtype=arr[time_field].dtype)
            # Republish
            self.pub.publish(array_to_cloud(arr, msg))
        except Exception as e:
            self.get_logger().warn(f"Cloud time fix failed: {e}")

def main():
    rclpy.init()
    node = CloudTimeFix()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
