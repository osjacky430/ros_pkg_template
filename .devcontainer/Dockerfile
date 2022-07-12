ARG ROS_VERSION="noetic"
FROM ros:${ROS_VERSION}

WORKDIR /root
COPY .devcontainer/build_script/install-llvm.sh \
  .devcontainer/build_script/install-mold.sh \
  .devcontainer/build_script/install-iwyu.sh \
  .devcontainer/build_script/install-cmake.sh \
  ./

RUN chmod +x install-llvm.sh install-mold.sh install-iwyu.sh install-cmake.sh
RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends git ninja-build wget python3-pip ccache cppcheck && \
  ./install-mold.sh && ./install-cmake.sh

ARG LLVM_VERSION="14"
ARG USE_CLANG
ARG USE_IWYU=1
RUN if [ "${USE_CLANG}" = "1" ] || [ "${USE_IWYU}" = "1" ]; then ./install-llvm.sh ${LLVM_VERSION}; fi
RUN if [ "${USE_IWYU}" = "1" ]; then ./install-iwyu.sh ${LLVM_VERSION}; fi

RUN python3 -m pip install --upgrade pip && \
  python3 -m pip install gcovr cmake-format catkin_tools
RUN apt-get autoremove -y && apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm install-cmake.sh install-mold.sh install-llvm.sh install-iwyu.sh

# if --build-arg USE_CLANG=1, set CC to 'clang' or set to null otherwise.
ENV CC=${USE_CLANG:+"clang"}
ENV CXX=${USE_CLANG:+"clang++"}
# if CC is null, set it to 'gcc' (or leave as is otherwise).
ENV CC=${CC:-"gcc"}
ENV CXX=${CXX:-"g++"}

RUN mkdir -p /home/catkin_ws/src/ros_pkg_template && \
  . /opt/ros/${ROS_DISTRO}/setup.sh && \
  cd /home/catkin_ws && catkin init

ENTRYPOINT [ "/ros_entrypoint.sh" ]