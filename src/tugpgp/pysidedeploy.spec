[app]

# title of your application
title = tugpgp

# project directory. the general assumption is that project_dir is the parent directory
# of input_file
project_dir = /home/ubuntu/tugpgp/src/tugpgp

# source file path
input_file = /home/ubuntu/tugpgp/src/tugpgp/app.py

# directory where exec is stored
exec_directory = /home/ubuntu/tugpgp/src/tugpgp

# path to .pyproject project file
project_file = tugpgp.pyproject

# application icon
icon = /home/ubuntu/tugpgp/.venv/lib/python3.10/site-packages/PySide6/scripts/deploy_lib/pyside_icon.jpg

[python]

# python path
python_path = /home/ubuntu/tugpgp/.venv/bin/python3

# python packages to install
packages = Nuitka==2.4.9,johnnycanencrypt

# buildozer = for deploying Android application
android_packages = buildozer==1.5.0,cython==0.29.33

[qt]

# comma separated path to qml files required
# normally all the qml files required by the project are added automatically
qml_files = SaveDir.qml,UserDetails.qml,Pins.qml,TButton.qml,main.qml,Yubikey.qml,WaitGlass.qml,Start.qml,Final.qml,UploadSucess.qml,Errors.qml,sunet_logo_color.svg,check-big.svg,errors.svg,hour-glass.svg,upload_success.svg,warning.svg,yk.png

# excluded qml plugin binaries
excluded_qml_plugins = QtCharts,QtQuick3D,QtSensors,QtTest,QtWebEngine

# qt modules used. comma separated
modules = Gui,Quick,OpenGL,Core,Qml,QmlMeta,QmlModels,Network,QuickControls2,DBus,QmlWorkerScript,QuickTemplates2

# qt plugins used by the application
plugins = accessiblebridge,qmltooling,scenegraph,tls,platformthemes,iconengines,networkinformation,generic,platforminputcontexts,platforms,xcbglintegrations,egldeviceintegrations,imageformats,networkaccess

# removed accessiblebridge and networkaccess

[android]

# path to pyside wheel
wheel_pyside = 

# path to shiboken wheel
wheel_shiboken = 

# plugins to be copied to libs folder of the packaged application. comma separated
plugins = 

[nuitka]

# usage description for permissions requested by the app as found in the info.plist file
# of the app bundle
# eg = extra_args = --show-modules --follow-stdlib
macos.permissions = 

# mode of using nuitka. accepts standalone or onefile. default is onefile.
mode = onefile

# (str) specify any extra nuitka arguments
extra_args = --quiet --noinclude-qt-translations

[buildozer]

# build mode
# possible options = [release, debug]
# release creates an aab, while debug creates an apk
mode = debug

# contrains path to pyside6 and shiboken6 recipe dir
recipe_dir = 

# path to extra qt android jars to be loaded by the application
jars_dir = 

# if empty uses default ndk path downloaded by buildozer
ndk_path = 

# if empty uses default sdk path downloaded by buildozer
sdk_path = 

# other libraries to be loaded. comma separated.
# loaded at app startup
local_libs = 

# architecture of deployed platform
# possible values = ["aarch64", "armv7a", "i686", "x86_64"]
arch = 

