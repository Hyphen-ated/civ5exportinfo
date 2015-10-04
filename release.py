import os, sys, shutil
from distutils.core import setup

# Here is where you can set the name for the release zip file and for the install dir inside it.
version = "0.2"
installName = 'Civ5ExportInfoMod-' + version

# target is where we assemble our final install. dist is where py2exe produces exes and their dependencies
if os.path.isdir('target/'):
    shutil.rmtree('target/')
installDir = 'target/' + installName + '/'

shutil.copytree('Export Info/FrontEnd', installDir + "FrontEnd/")

shutil.copy('Export_Info.Civ5Pkg', installDir)
shutil.copy('README.md', installDir + 'README.txt')

shutil.make_archive("target/[mod] Export Info v" + version, "zip", 'target', installName + "/")