

python
import pandas as pd
import os
import shutil
import math
import random
import time
from scipy.spatial.transform import Rotation as R

cmd.delete("all")

#get list of proteins
x = pd.read_csv("amino_list.csv")
num_rot = 1
list_proteins = x["amino_acid"].tolist()

list_proteins = [protein for protein in list_proteins if len(str(protein)) ==3]
print(list_proteins)

#remove previous folders
#for folder in ["aa_train", "aa_val", "aa_original"]:
for folder in ["aa_train", "aa_val", "aa_original"]:
  if not os.path.exists(folder):
    os.makedirs(folder)
  #else:
    #shutil.rmtree(folder)
    #os.makedirs(folder)

for protein in list_proteins:
  print(protein)

  #remove all cmds
  cmd.delete("all")
  cmd.reset()
  cmd.fetch(protein)

  #show only selection
  cmd.hide("all")
  cmd.show("sticks")
  cmd.color("grey", " (name C*)")

  cmd.set("ray_trace_color", "black")
  cmd.set("stick_ball", "on")
  cmd.set("stick_ball_ratio", 3)
  cmd.set("stick_radius", .12)
  #rotate and take png's (random in training folder)
  for a in range(num_rot):
    for b in range(num_rot):
      for c in range(num_rot):

        for test_folder in ["aa_train", "aa_val"]:

          if not os.path.exists(os.path.join(test_folder, protein)):
            os.makedirs(os.path.join(test_folder, protein))

          if test_folder == "aa_train":
            a_ang = a * 36
            b_ang = b * 36
            c_ang = c * 36
          else:
            # technically should be xyz, so corrected here, had 'zxy' originally (which should still lead to a random distribution and be correct for this application)
            # https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.transform.Rotation.random.html # please double check this is applied correctly
            angles = R.random().as_euler('xyz', degrees=True)
            a_ang = int(angles[0])
            b_ang = int(angles[1])
            c_ang = int(angles[2])

          cmd.rotate(axis = "x", angle = a_ang)
          cmd.rotate(axis = "y", angle = b_ang)
          cmd.rotate(axis = "z", angle = c_ang)
          cmd.refresh()

          cmd.png(os.path.join(test_folder, protein, "%s_%s_%s_%s.png" % (protein,  a_ang, b_ang, c_ang)), dpi=500, ray=1)

          print(os.path.join(test_folder, protein, "%s_%s_%s_%s.png" % (protein, a_ang, b_ang, c_ang)))
          cmd.rotate(axis = "z", angle = -c_ang)
          cmd.rotate(axis = "y", angle = -b_ang)
          cmd.rotate(axis = "x", angle = -a_ang)

          cmd.refresh()
          cmd.reset()

python end
