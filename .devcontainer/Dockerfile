ARG ROS_VERSION="noetic"
ARG LLVM_VERSION="14"

FROM ros:${ROS_VERSION} AS CI

WORKDIR /root
COPY .devcontainer/build_script/install-llvm.sh \
  .devcontainer/build_script/install-mold.sh \
  .devcontainer/build_script/install-cmake.sh \
  ./

ARG LLVM_VERSION
ARG USE_CLANG

RUN chmod +x install-mold.sh install-llvm.sh install-cmake.sh
RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends git wget python3-pip ccache && \
  ./install-mold.sh && ./install-cmake.sh

RUN if [ "${USE_CLANG}" = "1" ]; then ./install-llvm.sh ${LLVM_VERSION}; fi

RUN python3 -m pip install --upgrade pip && \
  python3 -m pip install gcovr catkin_tools

RUN mkdir -p /home/catkin_ws/src/ros_pkg_template && \
  . /opt/ros/${ROS_DISTRO}/setup.sh && \
  cd /home/catkin_ws && catkin init

# if --build-arg USE_CLANG=1, set CC to 'clang' or set to null otherwise.
ENV CC=${USE_CLANG:+"clang"}
ENV CXX=${USE_CLANG:+"clang++"}
# if CC is null, set it to 'gcc' (or leave as is otherwise).
ENV CC=${CC:-"gcc"}
ENV CXX=${CXX:-"g++"}

FROM CI AS DEV

ARG LLVM_VERSION
ARG USE_IWYU=1
COPY .devcontainer/build_script/install-devtool.sh ./

RUN chmod +x install-devtool.sh
RUN ./install-devtool.sh ${LLVM_VERSION} ${USE_IWYU}

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends cppcheck

RUN python3 -m pip install --upgrade pip cmake-format
RUN apt-get autoremove -y && apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm install-cmake.sh install-mold.sh install-llvm.sh install-devtool.sh

ENTRYPOINT [ "/ros_entrypoint.sh" ]