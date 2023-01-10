
#create individual
#create_img("reiske", "none", "6KLV", 501, "fes", "A", 0, 0, 324, True, save = False)
#create_img(name, folder, protein, resi, resn, chain, a_ang, b_ang, c_ang, hide_metal, save = True)


#cmd.set("cartoon_side_chain_helper", "on")
#cmd.show('cartoon')

python
import pandas as pd
import os
import shutil
import math
import random
import time
import numpy as np

#load list of proteins with angles already included (from previous "_by_protein" script)
df= pd.read_csv("record_images_metal_hidden_False_example_input.csv")

def resi_list_function(selection, metal):
 metal_list = []
 full_list = []
 atoms=cmd.get_model(selection)
 for at in atoms.atom:
      #put all info in a list
      full_list.append((at.resi, at.resn, at.chain))
      #only put metal info in the list
      if at.resn == metal:
        metal_list.append((at.resi, at.resn, at.chain))
 #set makes sure you aren't repeating atoms
 metal_list = list(set(metal_list))
 full_list = list(set(full_list))
 return metal_list, full_list


#rotate and take png's (random in train folder)
def create_img(metal, folder, protein, resi, resn, chain, a_ang, b_ang, c_ang, hide_metal, save = True):
 cmd.delete("all")

 cmd.reset()
 cmd.fetch(protein)

 #select everything within 6 ang of fes, fe
 selection_name = str(resi) + str(protein) + "_selection"
 cmd.select(selection_name, "byres(all within 6 of (resi " + str(resi) + " & resn " + str(resn) + " & Chain " + str(chain) + "))")

 #show only selection
 cmd.hide("all")
 cmd.show("sticks", selection_name)
 if hide_metal == True:
   cmd.hide("sticks", "resn " + resn)
 cmd.color("grey", " (name C*)")

 cmd.set("ray_trace_color", "black")
 cmd.set("stick_ball", "on")
 cmd.set("stick_ball_ratio", 3)
 cmd.set("stick_radius", .12)
 #cmd.set("depth_cue", 0 )
 #cmd.set('ray_shadows','off')
 cmd.zoom(selection_name, complete = 1, buffer = 2)
 cmd.hide("(hydro)")
 cmd.rotate(axis = "x", angle = a_ang)
 cmd.rotate(axis = "y", angle = b_ang)
 cmd.rotate(axis = "z", angle = c_ang)
 cmd.refresh()
 if save == True:
  cmd.png(os.path.join(folder, metal, "%s_%s_%s_%s_%s_%s_%s_%s.png" % (protein, metal, resi, resn, chain, a_ang, b_ang, c_ang)), dpi=500, ray=1)
 cmd.select("close_selection", "all within 3.5 of (resi " + str(resi) + " & resn " + str(resn) + " & Chain " + str(chain) + ")")
 _, full_list_3_5  = resi_list_function("close_selection", metal = metal)
 full_list_3_5 = [x[1] for x in full_list_3_5 ]

 _, full_list_6 = resi_list_function(selection_name, metal = metal)
 full_list_6 = [x[1] for x in full_list_6]
 cmd.refresh()


 a_dictionary = {"folder": folder, "protein": protein, "resi": resi, "resn": resn, "chain": chain, "a_ang":a_ang, "b_ang": b_ang, "c_ang": c_ang, "resn_3_5_radius": str(full_list_3_5), "resn_6_radius": str(full_list_6), str(hide_metal): str(hide_metal), 'metal': str(metal)}
 return a_dictionary


hide_metal = True

#remove previous folders
for folder in ["train_no_metal", "test_no_metal"]:
  if not os.path.exists(folder):
    os.makedirs(folder)
#  else:
#    shutil.rmtree(folder)
#    os.makedirs(folder)



#save results here
df_results = pd.DataFrame([])
data = []


#add img for each of the cofactors
for index, row in df.iterrows():
    print(row)
    folder = row['folder']
    if folder == "train":
      folder = "train_no_metal"
    else:
      folder = "test_no_metal"
    resi = row['resi']
    resn = row['resn']
    chain = row['chain']
    protein = row['protein']
    metal = row['metal']

    #create folder for each cofactor to keep img organized for training/testing
    if not os.path.exists(os.path.join("test_no_metal", metal)):
      os.makedirs(os.path.join("test_no_metal", metal))

    if not os.path.exists(os.path.join("train_no_metal", metal)):
      os.makedirs(os.path.join("train_no_metal", metal))

    a_ang = row['a_ang']
    b_ang = row['b_ang']
    c_ang = row['c_ang']

    a_dictionary = create_img(metal, folder, protein, resi, resn, chain, a_ang, b_ang, c_ang, hide_metal)
    data.append(a_dictionary)

df_results = df_results.append(data, True)
import time
timestr = time.strftime("%Y%m%d-%H%M%S")
df_results.to_csv("record_images_metal_hiden_" + str(hide_metal) + "_" + str(timestr) + ".csv")


python end
