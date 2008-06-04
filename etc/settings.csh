#----------------------------------*-sh-*--------------------------------------
# =========                 |
# \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
#  \\    /   O peration     |
#   \\  /    A nd           | Copyright (C) 1991-2007 OpenCFD Ltd.
#    \\/     M anipulation  |
#-------------------------------------------------------------------------------
# License
#     This file is part of OpenFOAM.
#
#     OpenFOAM is free software; you can redistribute it and/or modify it
#     under the terms of the GNU General Public License as published by the
#     Free Software Foundation; either version 2 of the License, or (at your
#     option) any later version.
#
#     OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
#     ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#     FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#     for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with OpenFOAM; if not, write to the Free Software Foundation,
#     Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
# Script
#     settings.csh
#
# Description
#     Startup file for OpenFOAM
#     Sourced from OpenFOAM-??/etc/cshrc
#
#------------------------------------------------------------------------------
if ($?prompt && $?foamDotFile) then
    if ($?FOAM_VERBOSE) then
        echo "Executing: $foamDotFile"
    endif
endif

alias AddPath 'set path=(\!* $path) ; if ( ! -d \!* ) mkdir -p \!*'
alias AddLib 'setenv LD_LIBRARY_PATH \!*\:${LD_LIBRARY_PATH} ; if ( ! -d \!* ) mkdir -p \!*'


#- Add the system-specific executables path to the path
set path=($WM_PROJECT_DIR/bin $FOAM_INST_DIR/$WM_ARCH/bin $path)

#- Location of the jobControl directory
setenv FOAM_JOB_DIR $FOAM_INST_DIR/jobControl

setenv WM_DIR $WM_PROJECT_DIR/wmake
setenv WM_LINK_LANGUAGE c++
setenv WM_OPTIONS $WM_ARCH$WM_COMPILER$WM_PRECISION_OPTION$WM_COMPILE_OPTION

set path=($WM_DIR $path)

setenv FOAM_SRC $WM_PROJECT_DIR/src
setenv FOAM_LIB $WM_PROJECT_DIR/lib
setenv FOAM_LIBBIN $FOAM_LIB/$WM_OPTIONS
AddLib $FOAM_LIBBIN

setenv FOAM_APP $WM_PROJECT_DIR/applications
setenv FOAM_APPBIN $WM_PROJECT_DIR/applications/bin/$WM_OPTIONS
AddPath $FOAM_APPBIN

setenv FOAM_TUTORIALS $WM_PROJECT_DIR/tutorials
setenv FOAM_UTILITIES $FOAM_APP/utilities
setenv FOAM_SOLVERS $FOAM_APP/solvers

setenv FOAM_USER_LIBBIN $WM_PROJECT_USER_DIR/lib/$WM_OPTIONS
AddLib $FOAM_USER_LIBBIN

setenv FOAM_USER_APPBIN $WM_PROJECT_USER_DIR/applications/bin/$WM_OPTIONS
AddPath $FOAM_USER_APPBIN

setenv FOAM_RUN $WM_PROJECT_USER_DIR/run


# Location of third-party software
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set thirdParty=$WM_PROJECT_INST_DIR/ThirdParty


# Compiler settings
# ~~~~~~~~~~~~~~~~~
set WM_COMPILER_BIN=
set WM_COMPILER_LIB=

# Select compiler installation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# WM_COMPILER_INST = OpenFOAM | System
set WM_COMPILER_INST=OpenFOAM


switch ("$WM_COMPILER_INST")
case OpenFOAM:
    switch ("$WM_COMPILER")
    case Gcc43:
        setenv WM_COMPILER_DIR $thirdParty/gcc-4.3.0/platforms/$WM_ARCH$WM_COMPILER_ARCH
    breaksw
    case Gcc:
        setenv WM_COMPILER_DIR $thirdParty/gcc-4.2.2/platforms/$WM_ARCH$WM_COMPILER_ARCH
    breaksw
    endsw

    # Check that the compiler directory can be found
    if ( ! -d "$WM_COMPILER_DIR" ) then
        echo
        echo "Warning in $WM_PROJECT_DIR/etc/settings.csh:"
        echo "    Cannot find $WM_COMPILER_DIR installation."
        echo "    Please install this compiler version or if you wish to use the system compiler,"
        echo "    change the WM_COMPILER_INST setting to 'System' in this file"
        echo
    endif

    set WM_COMPILER_BIN="$WM_COMPILER_DIR/bin"
    set WM_COMPILER_LIB=$WM_COMPILER_DIR/lib${WM_COMPILER_LIB_ARCH}:$WM_COMPILER_DIR/lib
    breaksw
endsw

if ($?WM_COMPILER_BIN) then
    set path=($WM_COMPILER_BIN $path)

    if ($?LD_LIBRARY_PATH) then
        setenv LD_LIBRARY_PATH ${WM_COMPILER_LIB}:${LD_LIBRARY_PATH}
    else
        setenv LD_LIBRARY_PATH ${WM_COMPILER_LIB}
    endif
endif


# MICO
# ~~~~
setenv MICO_VERSION 2.3.12
setenv MICO_PATH $thirdParty/mico-$MICO_VERSION
setenv MICO_ARCH_PATH $MICO_PATH/platforms/$WM_OPTIONS
set path=($MICO_ARCH_PATH/bin $path)


# FoamX
# ~~~~~
setenv FOAMX_PATH $FOAM_UTILITIES/preProcessing/FoamX
#
# need csh equivalent for this?
# for FOAMX_CONFIG in \
#     $HOME/.$WM_PROJECT/$WM_PROJECT_VERSION/apps/FoamX \
#     $HOME/.$WM_PROJECT/apps/FoamX \
#     $WM_PROJECT_INST_DIR/site/$WM_PROJECT_VERSION/apps/FoamX \
#     $WM_PROJECT_INST_DIR/site/apps/FoamX \
#     $WM_PROJECT_DIR/etc/apps/FoamX \
#     ;
# do
#     [ -d $FOAMX_CONFIG ] && break
# done
# export FOAMX_CONFIG
#
setenv FOAMX_CONFIG $HOME/.$WM_PROJECT-$WM_PROJECT_VERSION/apps/FoamX
if ( ! -d $FOAMX_CONFIG ) then
    setenv FOAMX_CONFIG $WM_PROJECT_DIR/etc/apps/FoamX
endif


# Communications library
# ~~~~~~~~~~~~~~~~~~~~~~

switch ("$WM_MPLIB")
case OPENMPI:
    set ompi_version=1.2.6
    setenv OPENMPI_HOME $thirdParty/openmpi-$ompi_version
    setenv OPENMPI_ARCH_PATH $OPENMPI_HOME/platforms/$WM_OPTIONS

    # Tell OpenMPI where to find it's install directory
    setenv OPAL_PREFIX $OPENMPI_ARCH_PATH

    AddLib $OPENMPI_ARCH_PATH/lib
    AddPath $OPENMPI_ARCH_PATH/bin

    setenv FOAM_MPI_LIBBIN $FOAM_LIBBIN/openmpi-$ompi_version
    unset ompi_version
    breaksw

case LAM:
    set lam_version=7.1.4
    setenv LAMHOME $thirdParty/lam-$lam_version
    setenv LAM_ARCH_PATH $LAMHOME/platforms/$WM_OPTIONS

    AddLib $LAM_ARCH_PATH/lib
    AddPath $LAM_ARCH_PATH/bin

    setenv FOAM_MPI_LIBBIN $FOAM_LIBBIN/lam-$lam_version
    unset lam_version
    breaksw

case MPICH:
    set mpich_version=1.2.4
    setenv MPICH_PATH $thirdParty/mpich-$mpich_version
    setenv MPICH_ARCH_PATH $MPICH_PATH/platforms/$WM_OPTIONS
    setenv MPICH_ROOT $MPICH_ARCH_PATH

    AddLib $MPICH_ARCH_PATH/lib
    AddPath $MPICH_ARCH_PATH/bin

    setenv FOAM_MPI_LIBBIN $FOAM_LIBBIN/mpich-$mpich_version
    unset mpich_version
    breaksw

case MPICH-GM:
    setenv MPICH_PATH /opt/mpi
    setenv MPICH_ARCH_PATH $MPICH_PATH
    setenv MPICH_ROOT $MPICH_ARCH_PATH
    setenv GM_LIB_PATH /opt/gm/lib64

    AddLib $MPICH_ARCH_PATH/lib
    AddLib $GM_LIB_PATH
    AddPath $MPICH_ARCH_PATH/bin

    setenv FOAM_MPI_LIBBIN $FOAM_LIBBIN/mpich-gm
    breaksw

case GAMMA:
    setenv GAMMA_ARCH_PATH /usr

    # AddLib $GAMMA_ARCH_PATH/lib
    # AddPath $GAMMA_ARCH_PATH/bin

    setenv FOAM_MPI_LIBBIN $FOAM_LIBBIN/gamma
    breaksw

case MPI:
    setenv FOAM_MPI_LIBBIN $FOAM_LIBBIN/mpi
    breaksw

default:
    setenv FOAM_MPI_LIBBIN $FOAM_LIBBIN/dummy
    breaksw
endsw

AddLib $FOAM_MPI_LIBBIN


# Set the MPI buffer size (used by all platforms except SGI MPI)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
setenv MPI_BUFFER_SIZE 20000000


# CGAL library if available
# ~~~~~~~~~~~~~~~~~~~~~~~~~
if ( $?CGAL_LIB_DIR ) then
    AddLib $CGAL_LIB_DIR
endif


# Switch on the hoard memory allocator if available
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#if ( -f $FOAM_LIBBIN/libhoard.so ) then
#    setenv LD_PRELOAD $FOAM_LIBBIN/libhoard.so:${LD_PRELOAD}
#endif


# -----------------------------------------------------------------------------
