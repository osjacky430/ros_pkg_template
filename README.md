# ros_pkg_template  <!-- omit in toc -->

[![Build Status](https://app.travis-ci.com/osjacky430/ros_pkg_template.svg?branch=master)](https://app.travis-ci.com/osjacky430/ros_pkg_template) [![CI](https://github.com/osjacky430/ros_pkg_template/actions/workflows/industrial_ci_action.yml/badge.svg)](https://github.com/osjacky430/ros_pkg_template/actions/workflows/industrial_ci_action.yml) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/eb9fe24089f34cc9b07c2cd23d2cf688)](https://www.codacy.com/gh/osjacky430/ros_pkg_template/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=osjacky430/ros_pkg_template&amp;utm_campaign=Badge_Grade)[![codecov](https://codecov.io/gh/osjacky430/ros_pkg_template/branch/master/graph/badge.svg?token=eMlsiHLKQ9)](https://codecov.io/gh/osjacky430/ros_pkg_template)[![CodeFactor](https://www.codefactor.io/repository/github/osjacky430/ros_pkg_template/badge)](https://www.codefactor.io/repository/github/osjacky430/ros_pkg_template)

- [Getting Started](#getting-started)
  - [Use the github template](#use-the-github-template)
  - [Remove things you are not going to use](#remove-things-you-are-not-going-to-use)
  - [Things that needs to be changed by you](#things-that-needs-to-be-changed-by-you)
- [Dependencies](#dependencies)
  - [Compiler, Build tools](#compiler-build-tools)
  - [ROS](#ros)
  - [Optional tools (Mostly C++ tools)](#optional-tools-mostly-c-tools)
- [Build](#build)
- [Unit Testing](#unit-testing)
- [TODO](#todo)
- [Reference](#reference)

## Getting Started

### Use the github template

Click the green button `use this template`, this will bring you to project generation page, after filling in all requried information, click "Create repository from template", and that's all! A repository is created in your Github account, just clone that newly created repository then you can start develop awesome ROS package!

![github template](https://user-images.githubusercontent.com/11375975/130358985-b3d14819-aee4-4994-bcc7-91822f9ef6bb.png)

### Remove things you are not going to use

This repository contains several ros examples, using `publisher/subscriber`, `services`, and `dynamic_reconfigure`. These examples will need certain files created under certain directory, if you are not going to use, say, dynamic_reconfigure, then in addition to delete the code related to it, you also need to remove the folder `cfg`, to do so:

``` sh
git rm -r <unnecessary_folders> # in the case mentioned above, <unnecessary_folders> will be "cfg"
```

For example, for non vscode user, you would like to `git rm -r .vscode`; for those whose project doesn't publish or advertise any custom services, `git rm -r msg` and `git rm -r srv`. Also, remember to remove unused ros dependencies in `package.xml`.

### Things that needs to be changed by you

**This part is not about modifying hpp/cpp files**, we only focus on `CMakeLists.txt` and other non cpp files. Some changes that needs to be done are obvious enough (if you didn't do it, cmake can't even pass configure stage) and are thus omitted here.

- Continuous Integration

  <details>
  <summary>Click to expand</summary>

    - Those badges, of course

    - github action (`.github/workflows/industrial_ci_action.yml`)
  
      - ~~`PKG_NAME`~~ (not valid until github action support top-level `env` variable substition)
      - `RT_FLAG` (and possibly files under `/tool/sanitizer`(TODO)) in job `run_sanitizer`, these are used to enable/disable sanitize flags during runtime

    - travis ci (WIP)

  </details>

- vscode user

  - `catkin_ws.path`, `ros.version`, and possibly `ros.path` in `.vscode/c_cpp_properties.json`

- ROS related:

  <details>
  <summary>Click to expand</summary>
  
  - `dynamic_reconfigure`
   
    - `PACKAGE` and `RECONFIGURE_NAME` in `cfg/RosPkgTemplateExample.cfg` (see [this](http://wiki.ros.org/dynamic_reconfigure/Tutorials/HowToWriteYourFirstCfgFile) for more detail)

  - `msg`/`srv`

    - Remember to add dependent messages/services in `package.xml`, otherwise even the project can compile in local machine, it won't pass CI since the dependencies are installed via `rosdep` 

  - cpp version

    - `CMAKE_CXX_STANDARD`, `CMAKE_CXX_STANDARD_REQUIRED` and `CMAKE_CXX_EXTENSIONS` in top-level `CMakeLists.txt` (recommend to change only `CMAKE_CXX_STANDARD`, or use `target_compile_options` instead of these three CMake variables)

  </details>

## Dependencies

### Compiler, Build tools

  - any versoin of gcc or clang will do since you can change the `CMAKE_CXX_STANDARD` to match the compiler you have

    - gcc

      ``` sh
      sudo apt install build-essential
      ```

    - clang

      ``` sh
      bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
      ```

  - CMake

    You probably want (and is recommended) to use latest version of CMake for almost all the time, see [here](https://cmake.org/download/) to download and install latest version cmake. Some CMake variables require CMake to be greater than certain version to work, for example:

    - [`CMAKE_CXX_CLANG_TIDY`](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_CLANG_TIDY.html): version greater than 3.6
    - [`check_ipo_supported`](https://cmake.org/cmake/help/latest/module/CheckIPOSupported.html), [`CMAKE_INTERPROCEDURAL_OPTIMIZATION`](https://cmake.org/cmake/help/latest/variable/CMAKE_INTERPROCEDURAL_OPTIMIZATION.html?highlight=cmake_interprocedural_optimization): version greater than 3.9
    - [`CMAKE_CXX_CPPCHECK`](https://cmake.org/cmake/help/v3.10/variable/CMAKE_LANG_CPPCHECK.html): version greater than 3.10.3
    - [`CMAKE_CXX_COMPILER_LAUNCHER`](https://cmake.org/cmake/help/latest/envvar/CMAKE_LANG_COMPILER_LAUNCHER.html): version greater than 3.17

### ROS

All ros dependencies should be able to be installed via `rosdep` (not an expert regarding rosdep, need to spend some time on it):

``` sh
rosdep install <your package name> # e.g. rosdep install ros_pkg_template
```

I personally prefer to only let `rosdep` handle dependencies that are also used by ros library implementation you depend on, for instance, boost, eigen, etc. For other dependencies that are not the case, such as [cgal](https://github.com/CGAL/cgal), use package manager e.g. [conan](https://github.com/conan-io/conan), or [vcpkg](https://github.com/microsoft/vcpkg) would be better. 

**Disclaimer: since I am a "you-should-always-use-the-latest-version-of-library" kind of guy, libraries installed from os pacakaging tool are almost always out of date, and therefore I would definitely not recommend it, lol.**

### Optional tools (Mostly C++ tools)

- [gcov](https://gcc.gnu.org/onlinedocs/gcc/Gcov.html) and [gcovr](https://gcovr.com/en/stable/) for code coverage report

  - gcov comes with gcc, see [previous section](#compiler-build-tools) regarding installation of gcc

  - gcovr can be installed via pip (see [here](https://gcovr.com/en/stable/installation.html) to check the python version each release supports)
  
    ``` sh
    pip install gcovr
    ```

- [ccache](https://ccache.dev/) or [sccache](https://github.com/mozilla/sccache) to speed up compilation (these require cmake version greater than 3.17)

  - ccache: see [here](https://github.com/ccache/ccache/blob/master/doc/INSTALL.md) to build from source, or just do the following

    ``` sh
    sudo apt-get install ccache
    ```

  - sccache: install via cargo (Rust package manager) or snap

    ``` sh
    sudo snap install sccache --candidate --classic
    ```
    or (this require Rust to be installed, literally build from source)

    ``` sh
    cargo install sccache
    ```

- [include-what-you-use](https://include-what-you-use.org/)

  This one is a bit tricky, you probably need to follow there [installation guide](https://github.com/include-what-you-use/include-what-you-use#how-to-build)

- [CPPcheck](http://cppcheck.sourceforge.net/)

  ``` sh
  sudo apt-get install cppcheck
  ```

- [clang-tidy](https://clang.llvm.org/extra/clang-tidy/)

  `clang-tidy` should come with [llvm nightly packages](https://apt.llvm.org/) already, if you do not have a clang compiler installed:

  ``` sh
  sudo apt-get install clang-tools
  ```

## Build

``` sh
catkin build --this
```

Most of the build options are in cmake helper script, but some aren't, e.g. CMAKE_BUILD_TYPE. Unfortunately, catkin doesn't provide any way to view all options in cmake. The only work around is to use `cmake-gui`, and manually specify build directory and source directory.

![cmake gui](https://user-images.githubusercontent.com/11375975/130358808-0988edc0-3d44-45e9-b9cf-f1219d26c797.png)

## Unit Testing

``` sh
catkin run_tests --this
```

Notice you must run `catkin build --this` before `catkin run_tests --this`, this can be easily forgotten and lead to some stupid mistake.

## TODO

1. refine CI logic
2. Add CI test for each cmake helper script functionality?
3. documentation on cmake helper script function
4. cppcheck flag is not generic enough

## Reference

1. [cpp_starter_project](https://github.com/lefticus/cpp_starter_project), most of the CMake scripts under `cmake` are from this template repository
2. [Professional CMake_ A Practical Guide (2018)](https://crascit.com/professional-cmake/) by Craig Scott