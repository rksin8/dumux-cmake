# One click install script for dumux
echo " "
echo " "
echo "*********************************************************************************************"
echo "(0/3) Checking all prerequistes. (git gcc g++ cmake pkg-config paraview)"
echo "*********************************************************************************************"

# check some prerequistes
for PRGRM in wget git gcc g++ cmake pkg-config; do
    if ! [ -x "$(command -v $PRGRM)" ]; then
        echo "ERROR: $PRGRM is not installed." >&2
        exit 1
    fi
done

if ! [ -x "$(command -v paraview)" ]; then
    echo "*********************************************************************************************"
    echo "WARNING: paraview seems to be missing. You may not be able to view simulation results!" >&2
    echo "*********************************************************************************************"
fi

currentver="$(gcc -dumpversion)"
requiredver="7"
if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" != "$requiredver" ]; then
    echo "gcc greater than or equal to $requiredver is required for dumux releases >=3.2!" >&2
    exit 1
fi

if [ $? -ne 0 ]; then
    echo "*********************************************************************************************"
    echo "(0/3) An error occured while checking for prerequistes."
    echo "*********************************************************************************************"
    exit $?
else
    echo "*********************************************************************************************"
    echo "(1/3) All prerequistes found."
    echo "*********************************************************************************************"
fi


DUMUX_VERSION=3.2

# make a new folder containing everything
mkdir -p $(pwd)/dumux$DUMUX_VERSION
cd dumux$DUMUX_VERSION

echo "*********************************************************************************************"
echo "(1/3) Cloning repositories. This may take a while. Make sure to be connected to the internet."
echo "*********************************************************************************************"

DUNE_VERSION=2.7
# the core modules
for MOD in common istl localfunctions geometry grid
do
    if [ ! -d "dune-$MOD" ]; then
        git clone -b releases/$DUNE_VERSION https://gitlab.dune-project.org/core/dune-$MOD.git
    else
        echo "Skip cloning dune-$MOD because the folder already exists."
    fi
done


#dune-typetree, functions
for MOD in typetree functions uggrid
do
	if [ ! -d "dune-$MOD" ]; then
		git clone -b releases/$DUNE_VERSION https://gitlab.dune-project.org/staging/dune-$MOD.git
	else
		echo "Skip cloning dune-typetree because the folder already exists."
	fi
done


SUGGESTED_MODULE="Yes"
if [$SUGGESTED_MODULE=="Yes"]; then
   echo "Installing suggested packages...!"
fi
#dune-alugrid
#if [ ! -d "dune-alugrid" ]; then
#	git clone -b releases/$DUNE_VERSION https://gitlab.dune-project.org/extensions/dune-alugrid.git
#else
#        echo "Skip cloning dune-alugrid because the folder already exists."
#fi


#dune-alugrid
#if [ ! -d "dune-functions" ]; then
#	git clone -b releases/$DUNE_VERSION https://gitlab.dune-project.org/staging/dune-functions.git
#else
#        echo "Skip cloning dune-functions because the folder already exists."
#fi


# pdelab
#if [ ! -d "dune-pdelab" ]; then
#    git clone -b releases/$DUNE_VERSION https://gitlab.dune-project.org/pdelab/dune-pdelab.git
#else
#    echo "Skip cloning dune-pdelab because the folder already exists."
#fi

if [ $? -ne 0 ]; then
    echo "*********************************************************************************************"
    echo "(1/3) Failed to clone the repositories. Look for repository specific errors."
    echo "*********************************************************************************************"
    exit $?
else
    echo "*********************************************************************************************"
    echo "(2/3) All repositories have been cloned into a containing folder."
    echo "*********************************************************************************************"
fi

echo " "

echo "**************************************************************************************************"
echo "(2/3) Configure and build dune modules and dumux using dunecontrol. This may take several minutes."
echo "**************************************************************************************************"

# run dunecontrol
if [ ! -f "cmake.opts" ]; then
#    wget https://git.iws.uni-stuttgart.de/dumux-repositories/dumux/-/raw/releases/3.2/cmake.opts
     wget https://raw.githubusercontent.com/rksin8/dumux-cmake/master/cmake.opts
else
    echo "A cmake.opts file already exists. The existing file will be used to configure dumux."
fi

./dune-common/bin/dunecontrol --opts=cmake.opts all

#./dune-common/bin/dunecontrol all

if [ $? -ne 0 ]; then
    echo "*********************************************************************************************"
    echo "(2/3) Failed to build the dune libaries."
    echo "*********************************************************************************************"
    exit $?
else
    echo "*****************************************************************************************************"
    echo "(3/3) Succesfully configured and built dune and dumux."
    echo "*****************************************************************************************************"
fi
