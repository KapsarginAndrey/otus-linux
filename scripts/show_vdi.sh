#!/bin/bash
listdisk=$(vboxmanage list hdds | grep UUID)
echo $listdisk

