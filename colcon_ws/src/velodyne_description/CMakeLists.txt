cmake_minimum_required(VERSION 3.8)
project(velodyne_description)

find_package(ament_cmake REQUIRED)

install(DIRECTORY launch meshes rviz urdf world
        DESTINATION share/${PROJECT_NAME}
)

ament_package()

