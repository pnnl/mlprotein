
python
import pandas as pd
import os
import shutil
import math
import random
import time
import numpy as np
from scipy.spatial.transform import Rotation as R

#number of runs to do
num_rot_train = 10#len(angle_comb)
num_rot_test = 5

hide_metal = False

#load list of proteins with repeated protein/resi removed
df= pd.read_csv("test_record_images_molql_example_input.csv")

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
 print(protein)

 #select everything within 6 ang of fes, fe
 selection_name = "selection_image"
 cmd.select(selection_name, "byres(all within 6 of (resi " + str(resi) + " & resn " + str(resn) + " & Chain " + str(chain) + "))")

 cmd.select("close_selection", "all within 3.5 of (resi " + str(resi) + " & resn " + str(resn) + " & Chain " + str(chain) + ")")

 _, full_list_3_5  = resi_list_function("close_selection", metal = resn)
 full_list_3_5 = [x[1] for x in full_list_3_5 ]
 cmd.refresh()

 _, full_list_6 = resi_list_function(selection_name, metal = resn)
 full_list_6 = [x[1] for x in full_list_6]
 cmd.refresh()

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
 cmd.set("depth_cue", 0 )
 cmd.set('ray_shadows','off')
 cmd.zoom(selection_name, complete = 1, buffer = 2)

 cmd.hide("(hydro)")
 cmd.rotate(axis = "x", angle = a_ang)
 cmd.rotate(axis = "y", angle = b_ang)
 cmd.rotate(axis = "z", angle = c_ang)
 cmd.refresh()
 if save == True:
  cmd.png(os.path.join(folder, metal, "%s_%s_%s_%s_%s_%s_%s_%s.png" % (protein, metal, resi, resn, chain, a_ang, b_ang, c_ang)), dpi=500, ray=1)

 cmd.refresh()
 a_dictionary = {"protein": protein, "resi": resi, "resn": resn, "chain": chain, "a_ang":a_ang, "b_ang": b_ang, "c_ang": c_ang, "resn_3_5_radius": str(full_list_3_5), "resn_6_radius": str(full_list_6), "hide_metal": str(hide_metal), 'metal': str(metal), 'folder': folder}
 return a_dictionary



#remove previous folders
for folder in ["train", "test"]:
  if not os.path.exists(folder):
    os.makedirs(folder)
  #else:
  #  shutil.rmtree(folder)
  #  os.makedirs(folder)

#keep track of which folder to put things into
angle_comb  = []


df["protein"] = df["protein"].apply(lambda x: x[5:])

#create list of angles to cycle through
for a in range(10):
  for b in range(10):
    for c in range(10):
          a_ang = a * 36
          b_ang = b * 36
          c_ang = c * 36
          angle_comb.append((a_ang, b_ang, c_ang))

#save results here
df_results = pd.DataFrame([])
data = []




#add img for each of the cofactors
for metal in  ["FES", "FE", "Rieske"]: #  if only some metals: ["FE"]:

    #get list of where metals are located

      current_list =list(np.where(df['folder2'] == metal)[0])
      print(current_list)
      #total proteins that contain that protein
      proteins_set = list(set([x[0] for x in df.iloc[current_list, [2]].values.tolist()]))
      print("hi")
      print(df.iloc[current_list, [2]].values.tolist())
      #suffle proteins
      random.shuffle(proteins_set)

      protein_dict = {}

      #keep track of which resi number per protein you are working with
      for protein in proteins_set:
        #start at first row
        current_resi = 0
        #get all resi with protein name and correct cofactor
        rows_protein = df.loc[(df['protein'] == protein) & (df['folder2'] == metal)]
        #rows (unique resi) per protein
        total_resi = rows_protein.shape[0]
        protein_dict[protein] = {"total_resi": total_resi, "current_resi": current_resi}

      #half of proteins to train, half to test
      train_proteins = proteins_set[:round(len(proteins_set)*.65)]
      test_proteins  = list(set(proteins_set) - set(train_proteins))

      #create folder for each cofactor to keep img organized for training/testing
      if not os.path.exists(os.path.join("test", metal)):
        os.makedirs(os.path.join("test", metal))

      if not os.path.exists(os.path.join("train", metal)):
        os.makedirs(os.path.join("train", metal))

      #keep track of number of rotations completed
      train_rot = 0
      test_rot = 0

      #keep track of position in the protein_train/protein_test list
      i = 0
      j = 0



      #multiple current list to repeat for one his fes metallocenters
      while train_rot < num_rot_train:
        train_rot += 1

        folder = "train"

        #length of train_proteins
        if i == len(train_proteins):
          i = 0
        print(i)
        protein = train_proteins[i]
        i += 1
        print(protein)
        #get rows with that cofactor and protein
        rows_protein = df.loc[(df['protein'] == protein) & (df['folder2'] == metal)]
        print(rows_protein)
        #keep track of which resi have already been used from protein, cycle thought them
        #go back to first unique resi if used all
        if protein_dict[protein]["current_resi"] == protein_dict[protein]["total_resi"]:
          protein_dict[protein]["current_resi"] = 0
          #get row number you should use froms rows_proteins
          protein_position = protein_dict[protein]["current_resi"]
          protein_dict[protein]["current_resi"] +=1

        else:
          protein_position = protein_dict[protein]["current_resi"]
          protein_dict[protein]["current_resi"] +=1

        #use row
        row = rows_protein.iloc[protein_position]
        print(row)
        resi = row['resi']
        resn = row['resn']
        chain = row['chain']
        protein_in_row = row['protein']
        if protein_in_row != protein:
          print("protein doesn't match")


        #get remainder when divide by length of angle
        #minus 1 to get right indexing for python
        num_angle_comb = train_rot % len(angle_comb) -1

        a_ang = angle_comb[num_angle_comb][0]
        b_ang = angle_comb[num_angle_comb][1]
        c_ang = angle_comb[num_angle_comb][2]
        print((metal, folder, protein, resi, resn, chain, a_ang, b_ang, c_ang, hide_metal))
        a_dictionary = create_img(metal, folder, protein, resi, resn, chain, a_ang, b_ang, c_ang, hide_metal)
        data.append(a_dictionary)

      while test_rot < num_rot_test:
        test_rot += 1

        folder = "test"

        #length of test_proteins
        if j == len(test_proteins):
          j = 0

        protein = test_proteins[j]
        j += 1

        #get rows with that cofactor and protein
        rows_protein = df.loc[(df['protein'] == protein) & (df['folder2'] == metal)]

        #keep track of which resi have already been used from protein, cycle thought them
        #go back to first unique resi if used all
        if protein_dict[protein]["current_resi"] == protein_dict[protein]["total_resi"]:
          protein_dict[protein]["current_resi"] = 0
          #get row number you should use froms rows_proteins
          protein_position = protein_dict[protein]["current_resi"]
          protein_dict[protein]["current_resi"] +=1

        else:
          protein_position = protein_dict[protein]["current_resi"]
          protein_dict[protein]["current_resi"] +=1

        #use row
        row = rows_protein.iloc[protein_position]

        resi = row['resi']
        resn = row['resn']
        chain = row['chain']
        protein_in_row = row['protein']
        if protein_in_row != protein:
          print("protein doesn't match")

        # technically should be xyz, so corrected here, had 'zxy' originally (which should still lead to a random distribution and be correct for this application)
        # https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.transform.Rotation.random.html # please double check this is applied correctly
        angles = R.random().as_euler('xyz', degrees=True)
        a_ang = int(angles[0])
        b_ang = int(angles[1])
        c_ang = int(angles[2])


        a_dictionary = create_img(metal, folder, protein, resi, resn, chain, a_ang, b_ang, c_ang, hide_metal)
        data.append(a_dictionary)


df_results = df_results.append(data, True)
import time
timestr = time.strftime("%Y%m%d-%H%M%S")
df_results.to_csv("record_images_metal_hidden_" + str(hide_metal) + "_" + timestr + ".csv")
print(df["protein"])

python end
