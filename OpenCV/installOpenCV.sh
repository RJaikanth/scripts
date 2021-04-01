#####################################################
#           Script for installing OpenCV			#
#####################################################

INSTALL_DIR="/path/to/install/dir"
if [ "$INSTALL_DIR" = "/path/to/install/dir" ]; then
    echo "Please open script and update the variable 'INSTALL_DIR'"
    exit 1
fi
mkdir -p $INSTALL_DIR
CONTRIB=true




function installDependencies() {
    echo "+=================================================================";
    echo "|                 Installing Dependencies                        +";
    echo "+=================================================================";

    sudo apt-get -y update 
    sudo apt-get -y upgrade

    # Essentials
    sudo apt-get install -y clang dpkg-dev libc6-dev make cmake unzip pkg-config git doxygen

    # Image codecs
    sudo apt-get install -y libjpeg-dev libpng-dev libtiff-dev 

    # Install jasper
    sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
    sudo apt update
    sudo apt install libjasper1 libjasper-dev

    # Video codecs
    sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev

    # GTK GUI
    sudo apt-get install -y libgtk-3-dev

    # Math Libraries
    sudo apt-get install -y libatlas-base-dev gfortran

    # Python depdencies
    sudo apt-get install python3.6-pip python3.6-dev 
}

function cloneLibraries() {
    echo "+=================================================================";
    echo "|                    Cloning Libraries                           +";
    echo "+=================================================================";
    git clone https://github.com/opencv/opencv.git
    
    if $CONTRIB; then; do
        echo "Contrib is set to true, we will install the contrib libraries as well" 
        git clone https://github.com/opencv/opencv_contrib.git
    fi

}

function configureAndInstall() {
    # Move opencv_contrib into opencv
    mv opencv_contrib opencv

    # Make and cd to build folder
    mkdir -p opencv/build && cd opencv/build

    # Configure build
    cmake \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        -D BUILD_DOCS=ON \
        -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
        -D PYTHON_EXECUTABLE=~/.virtualenvs/cv/bin/python \
        -D OPENCV_ENABLE_NONFREE=ON  ..

    make -j$(nproc)
    make install
}

function createPythonEnvironment() {
    sudo apt-get install python3-pip
    sudo pip install virtualenv virtualenvwrapper

    echo -e "\n# virtualenv and virtualenvwrapper" >> ~/.bashrc
    echo "export WORKON_HOME=$HOME/.virtualenvs" >> ~/.bashrc
    echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
    source ~/.bashrc

    mkvirtualenv cv -p python3.6
    workon cv

    pip install numpy

}

function linkOpenCVBindings() {
    mv ./lib/python3/cv2.cpython-36m-x86_64-linux-gnu.so ./lib/python3/cv2.so
    BUILD_DIR=$(pwd)
    cd ~/.virtualenvs/cv/lib/python3.6/site-packages/
    ln -s $BUILD_DIR/lib/python3/cv2.so
}


# Install Dependencies
installDependencies();

# Clone git libraries
cloneLibraries();

# Set python environment
createPythonEnvironment();

# Configure and Install
configureAndInstall();

# Link OpenCV Bindings
linkOpenCVBindings();

echo 'export CMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH:/home/rjaikanth97/myspace/work/libs/installed/opencv/"' >> ~/.bashrc
