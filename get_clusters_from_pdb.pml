
python
import pandas as pd
import os
import shutil
import math
import random
import time


#update txt files with list of proteins and if metal should be record_images_metal_hidden

my_file = open("fe_small_example.txt", "r")
content = my_file.read()
fe_list = content.split(',')

my_file = open("fes_small_example.txt", "r")
content = my_file.read()
fes_list = content.split(',')

my_file = open("fe2_small_example.txt", "r")
content = my_file.read()
fe2_list = content.split(',')

#list of metals to look for
metal_list = ["FE", "FES", "FE2"]
#"SF4"

hide_metal = False

def resi_list_function(selection, metal = "FES"):
  metal_list = []
  full_list = []
  metal_list_full = []
  atoms=cmd.get_model(selection)
  for at in atoms.atom:
       #put all info in a list
       full_list.append((at.resi, at.resn, at.chain))
       #only put metal info in the list
       if at.resn == metal:
         print(at.name)
         metal_list.append((at.resi, at.resn, at.chain))
         metal_list_full.append((at.name))
  print(metal_list_full)
  #set makes sure you aren't repeating atoms
  metal_list_set = list(set(metal_list))
  full_list = list(set(full_list))
  return metal_list_set, full_list, metal_list_full

#remove previous folders
for folder in ["FE", "FES", "FE2", "Rieske", "Fes1His", "does_not_qualify"]:
  if not os.path.exists(folder):
    os.makedirs(folder)
  #else:
    #shutil.rmtree(folder)
    #os.makedirs(folder)
#rotate and take png's (random in train folder)
# create_img("6D62", "201", "FE2", "A")
def create_img(metal_name, protein, resi, resn, chain, save = True):
 print(protein, resi, resn, chain)
 cmd.delete("all")

 cmd.reset()
 cmd.refresh()
 cmd.fetch(protein)

 #select everything within 6 ang of fes, fe

 #add smaller circle to see how it works
 cmd.select("close_selection", "byres(all within 3 of (resi " + str(resi) + " & resn " + str(resn) + " & Chain " + str(chain) + "))")
 _, full_list_3,  metal_list_all = resi_list_function("close_selection", metal = metal)
 full_list_3 = [x[1] for x in full_list_3 ]


 if full_list_3.count("CYS") >= 4 and full_list_3.count("HIS") == 0 and metal_list_all.count("FE") == 1:
    folder = "FE"
 elif full_list_3.count("CYS") >= 4 and full_list_3.count("HIS") == 0 and metal_list_all.count("FE1") == 1 and metal_list_all.count("FE2") == 1:
    folder = "FES"
 elif full_list_3.count("CYS") >= 2 and full_list_3.count("HIS") == 2 and metal_list_all.count("FE1") == 1 and metal_list_all.count("FE2") == 1:
    folder = "Rieske"
 elif full_list_3.count("CYS")  >= 3 and full_list_3.count("HIS") == 1 and metal_list_all.count("FE1") == 1 and metal_list_all.count("FE2") == 1:
    folder = "Fes1His"
 else:
    folder = "does_not_qualify"
 #show only selection
 cmd.hide("all")
 cmd.show("sticks", "close_selection")
 cmd.color("grey", " (name C*)")

 cmd.set("ray_trace_color", "black")
 cmd.set("stick_ball", "on")
 cmd.set("stick_ball_ratio", 3)
 cmd.set("stick_radius", .12)
 cmd.set("depth_cue", 0 )
 cmd.set('ray_shadows','off')
 cmd.zoom("close_selection", complete = 1, buffer = 2)

 cmd.refresh()
 image_list = []
 if save == True and (protein, metal_name, resi, resn, chain) not in image_list:
  image_list.append((protein, metal_name, resi, resn, chain))
  cmd.png(os.path.join(folder, "%s_%s_%s_%s_%s.png" % ( protein, metal_name, resi, resn, chain)), dpi=500, ray=1)

  cmd.rotate(axis = "x", angle = 90)
  cmd.rotate(axis = "y", angle = 90)
  cmd.rotate(axis = "z", angle = 90)
  cmd.png(os.path.join(folder, "%s_%s_%s_%s_%s.png" % (protein, resi, resn, chain, "repeat")), dpi=500, ray=1)


#add smaller circle to see how it works
 cmd.select("closer_selection", "all within 2.5 of (resi " + str(resi) + " & resn " + str(resn) + " & Chain " + str(chain) + ")")
 _, full_list_2_5, _  = resi_list_function("closer_selection", metal = metal)
 full_list_2_5 = [x[1] for x in full_list_2_5 ]

 cmd.refresh()

 #add smaller circle to see how it works
 cmd.select("closest_selection", "all within 1.5 of (resi " + str(resi) + " & resn " + str(resn) + " & Chain " + str(chain) + ")")
 _, full_list_1_5, _  = resi_list_function("closest_selection", metal = metal)
 full_list_1_5 = [x[1] for x in full_list_1_5 ]

 a_dictionary = {"protein": "name:" + str(protein), "resi": str(resi), "resn": str(resn), "chain": str(chain),  "resn_2_5_radius": str(full_list_2_5), "resn_3_radius": str(full_list_3), "resn_1_5_radius": str(full_list_1_5), "cys_num": full_list_3.count("CYS"), "his_num": full_list_3.count("HIS"), "fes_num": full_list_3.count("FES"), "fe_num": full_list_3.count("FE"), "fe2_num": full_list_3.count("FE2"), "metal_atom_names": str(metal_list_all), "folder": str(folder)}
 return a_dictionary


cmd.delete("all")

#save results here
df_results = pd.DataFrame([])
data = []

for metal in metal_list:
  if metal == "FE":
    list_proteins = fe_list
  elif metal == "FES":
    list_proteins = fes_list
  else:
    list_proteins = fe2_list

  for protein in list_proteins:

    #remove all cmds
    cmd.delete("all")
    cmd.fetch(protein)

    #get list of all resi and resn in protein
    metal_list2, _, _ = resi_list_function("all", metal = metal)

    for metal_tuple in metal_list2:

      print(metal_tuple)
      #select atoms within dist of selection by resn, resi, chain
      resi = metal_tuple[0]
      resn = metal_tuple[1]
      chain = metal_tuple[2]

      a_dictionary = create_img(metal, protein, resi, resn, chain)

      data.append(a_dictionary)

df_results = df_results.append(data, True)
import time
timestr = time.strftime("%Y%m%d-%H%M%S")
df_results.to_csv("record_images" + "_" + str(timestr) + ".csv", float_format='%f')




python end
