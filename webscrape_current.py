

import time
from selenium import webdriver
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By
import os

import os
from pathlib import Path
from datetime import datetime, timedelta, timezone
import pandas as pd
import glob
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager

##needs to be a file as already been through pymol scirpt - replace line below
#metallo_df = pd.read_csv("record_images_20220212-221912.csv")
metallo_df = pd.read_csv("record_images_example_input.csv")
print(metallo_df)
driver = webdriver.Chrome(ChromeDriverManager().install())


#CHANGE TO LOCAL
dirpath = "/Users/oost464/Downloads/"

# URL of website
url = "http://molql.org/explorer.html"

#Opening the website
driver.get(url)

#byres (name Fe and resi 172 and chain A) extend 1
structure_dict = {"Cu ion": {"command": "byres name Cu extend 1", "structure_name": "Cu"}, "SF4": {"command": "byres resn SF4 extend 1", "structure_name": "SF4"},  "2Fe2S": {"command": "byres resn FES extend 1", "structure_name": "FES"}}

def close_res(x):

    if pd.notnull(x["protein"]):

        molecule = str(x["protein"][5:])
        resi = str(x["resi"])
        resn = str(x["resn"])
        chain = str(x["chain"]).upper()
        command = "byres (resn " + resn + " and resi " + resi + " and chain " + chain + ") extend 1"

        start_time = datetime.today()
        print(start_time)
        #first update loaded molecule
        text_input = driver.find_element_by_xpath("//input[@placeholder='PDB id...']")
        text_input.clear()
        text_input.send_keys(molecule)


        # download the molecule so can perform query on it
        download_button = driver.find_element_by_xpath('//button[text()="Download"]')
        download_button.click()


        dropdown = driver.find_element(By.CSS_SELECTOR, ".molql-logo .six:nth-child(1) > .u-full-width")
        dropdown.find_element(By.XPATH, "//option[. = 'Language: MolQL Script']").click()

        dropdown = driver.find_element(By.CSS_SELECTOR, ".molql-logo .six:nth-child(1) > .u-full-width")
        dropdown.find_element(By.XPATH, "//option[. = 'Language: PyMOL']").click()

        dropdown = driver.find_element(By.CSS_SELECTOR, ".molql-logo .six:nth-child(2) > .u-full-width")
        dropdown.find_element(By.XPATH, "//option[. = 'Select example...']").click()

        driver.find_element(By.CSS_SELECTOR, ".CodeMirror-lines").click()
        driver.find_element(By.CSS_SELECTOR, ".CodeMirror-scroll").click()
        driver.find_element(By.CSS_SELECTOR, "textarea").send_keys(command)


                #sometimes the molecule takes sometime to load, so don't want to start query until it loads (probably should make if loaded statement...)

        time.sleep(5)
        # getting the button by class name
        query_button = driver.find_element_by_xpath('//button[text()="Execute Query (Ctrl/Cmd + Enter)"]')
        query_button.click()


        #download all
        for link in driver.find_elements_by_link_text('mmCIF'):
            link.click()

        #take only the most recent cif files created with the start time of this loop of structures/molecules
        def get_information(directory):
            time.sleep(2)
            list_of_files = glob.glob(dirpath + "*") # * means all if need specific format then *.csv

            latest_file = max(list_of_files, key=os.path.getctime)
            a = os.stat(latest_file)
            if datetime.fromtimestamp(a.st_ctime) > start_time:
                cif_file = latest_file
            else:
                cif_file = "didn't download"

            return cif_file

        file = get_information(dirpath)
        x["cif_name"] = file
        if file[-4:] == '.cif':
            # #inital empty dataframe to add each cif file to for each protein
            amino_dataframe  = pd.DataFrame(columns=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21])

            #first open and remove the first 24 rows, which are all the title names
            df = pd.read_csv(file, delimiter = "\t", header=None)

            df = df.iloc[24:-1]
            if df.empty == False:
                df.to_csv(dirpath + "without_titles.txt", header=False)
                #re-read the csv file with whitespaces as delimiters
                df = pd.read_csv(dirpath + 'without_titles.txt', delimiter = " ", header=None)
                amino_dataframe = amino_dataframe.append(df, ignore_index=True)

                #keep only the ['Residue name', 'chain name', 'residue number', 'model number']
                amino_dataframe = amino_dataframe[[17, 18, 19, 20]]
                amino_dataframe = amino_dataframe.drop_duplicates()
                list_amino = amino_dataframe.iloc[:, 0].to_list()
                x["cys_num2"] = list_amino.count("CYS")
                x["fe_num2"] = list_amino.count("FE")
                x["fes_num2"] = list_amino.count("FES")
                x["his_num2"] = list_amino.count("HIS")
                x["all_amino_acids"] = str(list_amino)
                x["number of connections"] = len(list_amino)

                if list_amino.count("CYS") >= 4 and list_amino.count("HIS") == 0 and list_amino.count("FE") == 1:
                    folder = "FE"
                elif list_amino.count("CYS") >= 4 and list_amino.count("HIS") == 0 and list_amino.count("FES") == 1:
                    folder = "FES"
                elif list_amino.count("CYS") >= 2 and list_amino.count("HIS") == 2 and list_amino.count("FES") == 1:
                    folder = "Rieske"
                elif list_amino.count("CYS")  >= 3 and list_amino.count("HIS") == 1 and list_amino.count("FES") == 1:
                    folder = "Fes1His"
                else:
                    folder = "does_not_qualify"
                x["folder2"] = folder

    return x


file_path_csv = "test_record_images_molql.csv"
metallo_df = metallo_df[metallo_df['folder'] != "does_not_qualify"]
new_metallo_df = metallo_df.drop_duplicates(['protein','resi', 'resn'],keep= 'first').reset_index()
#need to do bit by bit so doesn't freeze up
new_metallo_df = new_metallo_df #.iloc[20:]
print(new_metallo_df)
for index, row in new_metallo_df.iterrows():
    print(row)
    row = pd.DataFrame(close_res(row)).T
    print(index)
    if index == 0:
        row.to_csv(file_path_csv, mode='w', index = False)
    row.to_csv(file_path_csv, mode='a', header=False, index = False)
# new_metallo_df = new_metallo_df.apply(close_res, axis=1)
# print(new_metallo_df)
# new_metallo_df.to_csv("record_final_amino_acids.csv")
