

Disclaimer

This material was prepared as an account of work sponsored by an agency of the United States Government.  Neither the United States Government nor the United States Department of Energy, nor Battelle, nor any of their employees, nor any jurisdiction or organization that has cooperated in the development of these materials, makes any warranty, express or implied, or assumes any legal liability or responsibility for the accuracy, completeness, or usefulness or any information, apparatus, product, software, or process disclosed, or represents that its use would not infringe privately owned rights.
Reference herein to any specific commercial product, process, or service by trade name, trademark, manufacturer, or otherwise does not necessarily constitute or imply its endorsement, recommendation, or favoring by the United States Government or any agency thereof, or Battelle Memorial Institute. The views and opinions of authors expressed herein do not necessarily state or reflect those of the United States Government or any agency thereof.
PACIFIC NORTHWEST NATIONAL LABORATORY
operated by
BATTELLE
for the
UNITED STATES DEPARTMENT OF ENERGY
under Contract DE-AC05-76RL01830

# PyMol Pipeline


Note: When inspecting pml files, make sure to open in a code editor, such as Atom. Your computer will want to open the pml files within PyMol, which will automatically run the script. Seeing as scripts add to or delete things, you don’t want to run them accidently.

Once you are ready to run, drop the pml file to PyMol to start the script.

At the beginning of every run, the folder “train” and “test” and all contents are deleted. This is to avoid accidently added images from multiple runs to the same folders. If you are happy with your run and don’t want anything deleted, rename the test and train folders. Uncomment ‘shutil.rmtree” if you want to accept this functionality

It’s important to update the current example input file names to the real file names. Each step will use the output file of the previous step.

# 1. get\_clusters\_from\_pdb.pml

Create initial list of metals with resi, resn and chain

Current input files (update): fe\_small\_example.txt, fes\_small\_example.txt, fe2\_small\_example.txt (update starting at line 13)


- This script runs for each protein in a txt file
- This script looks into a PyMol selection and returns either the list of metals (metal\_list) in a tuple of (resi, resn, chain) or all the items in the selection (full\_list), again in a tuple, with the function listselection (line 21)
- First the script uses the function listselection to return a list of metals in the entire protein
- Then the script loops through the list of metals and select resn within 3.0 radius of each metal. For each metal, it uses the full\_list of items within a 3.0 radius (line 71), to classify as a Fe, Fes, or Reiske.
- The script saves the protein, resi, resn, chain, and resn\_list within 3.0 radius to a csv file

# 2. Run the webscrapper\_current.py in python

Confirm classifications with MolQL

Current input files (update): record\_images\_example\_input.csv (update at line 19)


- Output file from the last step in line 19.
- Update your download location in line 25.
- Set up environment:

<https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#activating-an-environment>

```
conda create -n [webscrape\_env] python=3.7

pip install selenium==4.1.1

pip install pandas

pip install webdriver-manager
```



# 3. create\_png\_metal\_by\_protein.pml

Create the images for the neural network training and testing

Current input files (update): test\_record\_images\_molql\_example\_input.csv (added lines to the previous output from webscrapper to include all the metals, not just FES) (update at line 19)

- Set number of images per folder at line 13 and 14
- Indicate if you want to hide the metal at line 16
- This file will use the webscraper output, so update the filename in line 19
- Make sure the last column, with the proper cluster classification is called “folder2” and that the “protein” column is in the third column down in the input file
- The script will divide proteins per metal into test and train sets and randomize the order of the proteins
- The script creates a dictionary “protein\_dict” that keeps track of how many unique resi there are per protein, and which one you recently used.
- The script cycles through each protein and uses the next possible resi. Restart at the original resi once all resi per protein have been used.  
- For training data, each protein/resi is assigned a rotation from angle\_comb variable. You’ll want to update angle\_comb if you want to use different angles
- For test data, each protein/resi is assigned a random angle
- The data for each image is saved to a dictionary and written out in a csv starting with record\_images\_metal\_hidden\_ and ending with the time stamp



# 4. create\_png\_metal\_from\_excel.pml.

Using the output excel file, you can re-create the same images with the same rotations, but with the metal hidden

Current input files (update): record\_images\_metal\_hidden\_False\_example\_input.csv (update at line 20)

# 5. Run a modification of below script:
https://pytorch.org/tutorials/beginner/finetuning\_torchvision\_models\_tutorial.html

# 6. create\_aa\_pymol.pml  

Creates the amino acid image. It works the same way as the rotations for metals, and just needs to be run in PyMol.

Input files: amino\_list.csv

Simplified BSD
____________________________________________
Copyright 2023 Battelle Memorial Institute

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

Acknowledgement: This work is supported by the PNNL Laboratory Directed Research and Development (LDRD) program

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
