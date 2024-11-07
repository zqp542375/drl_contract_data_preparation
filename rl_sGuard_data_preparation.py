"""
Get RW data for small dataset.
Prepare for rw data for my reinforcement learning project
constructor: reads:[], writes:[initialized state variables and those read in constructors]
   collect rw data
"""
import os.path
import random

import pandas

from prepare.config import project_path
from prepare.contract_filter import digitalize_found_contracts, digitalize_svar, \
   find_contracts
from prepare.prepare_env_data import find_file_names_and_paths
from prepare.static_data_collection import collect_rw_data_slither, \
    collect_svar_slither

from prepare.utils import load_a_json_file,  dump_json_object_to_json
from prepare.prepare_env_data import find_file_names_and_paths, \
    parepare_contract_data_for_env_creation_0
from prepare.rl_sGuard_contract_data_for_env import contract_info_csv_file
from prepare.static_data_collection import collect_svar_slither, \
   collect_rw_data_slither
from prepare.contract_train_test import update_contract_data_in_integer, \
    divide_contracts, update_contract_data_in_integer_1, \
    group_contracts_map_functions_1
from utils import load_a_json_file,  dump_json_object_to_json


# ==================================================
# collect data for sGuard dataset
# collect contract data for sGuard dataset
NUM_actions=2
NUM_state_variables=16
MAX_svar_value=5740
MAX_func_value_element=70

rl_result_path = project_path + "results\\rl_related\\"
contract_seq_collection_result_path=project_path+"sequence_from_SE\\24_rl_seq_collection_tacc_results\\"
sGuard_contract_info_path_name =project_path+ "datasets\\sGuard_contracts\\sGuard_contracts_info.csv"

solidity_path = "../datasets/sGuard_contracts/"
dataset='sGuard'
date="8_19_2024"
contract_data=f"rl_{dataset}_contracts_data_{date}.json"
contract_svar_data=f"rl_{dataset}_svar_info_{date}.json"
contract_rw_data=f"rl_{dataset}_contracts_rw_data_{date}.json"
contract_data_for_env_construction=f'rl_{dataset}_contracts_data_for_env_construction_{date}_{NUM_state_variables}.json'
contract_data_for_env_construction_in_integer=f'rl_{dataset}_contracts_data_for_env_construction_{date}_{NUM_state_variables}_in_integer.json'

contract_info_csv_file=f"rl_{dataset}_contracts_info_exp_{date}_svar.csv"



if __name__=="__main__":

   svar_by_type={}
   contract_function_r_w={}
   contract_svar={}



   #***********************************************************
   """
   1, collect rw data using Slither
 
   to-do:
   need to set timeout for the function to compile contracts using Slither
   need to re-organize the code to prepare data for sGuard dataset
   """
   if not os.path.exists(rl_result_path+ contract_data):
       contract_svar,svar_by_type,contract_function_r_w=collect_rw_data_slither(solidity_path,[],contract_info_file_path_name=sGuard_contract_info_path_name)

       rl_contract_data={'contract_svar':contract_svar,'svar_by_type':svar_by_type,'contract_function_r_w':contract_function_r_w}

       dump_json_object_to_json(rl_contract_data,
                                rl_result_path+ contract_data)





   #***********************************************************
   """
   2, collect svar info
   """
   if not os.path.exists(rl_result_path + contract_svar_data):
       contract_svar_info=collect_svar_slither(solidity_path,[],contract_info_file_path_name=sGuard_contract_info_path_name)

       dump_json_object_to_json(contract_svar_info,
                                rl_result_path + contract_svar_data)


   #***********************************************************
   """
   3, collect required contracts: at least m functions that can write state variables (not constant)
   """
   if not os.path.exists(rl_result_path+ contract_rw_data):
       rl_contract_data=load_a_json_file(rl_result_path+ contract_data)
       contract_function_rw=rl_contract_data['contract_function_r_w']
       contracts_find=find_contracts(contract_function_rw,least_num_functions=3)


       #========================
       # digitalize the state variables of the found contract
       contract_svar_info=load_a_json_file(rl_result_path + contract_svar_data)
       svar_by_type,svar_to_int,int_to_svar=digitalize_svar(contracts_find,contract_svar_info)

       #========================
       # present state variables in integers for the found contracts
       found_contract_data_in_int=digitalize_found_contracts(contracts_find,contract_function_rw,contract_svar_info,svar_to_int)


       #============================
       all_data = {
          "svar_by_type": svar_by_type,
          "svar_to_int": svar_to_int,
          "int_to_svar": int_to_svar,
          "found_contract_data_in_int": found_contract_data_in_int,
       }

       dump_json_object_to_json( all_data,
          rl_result_path+ contract_rw_data)


   # # ***********************************************************
   """
    4. get the result file names and their paths (function sequences from symbolic execution)
       map state variables to integers
   """
   result_file_name_and_path = find_file_names_and_paths(contract_seq_collection_result_path)
   sGuard_contract_info_file_path_name=f'{rl_result_path}{contract_info_csv_file}'
   df_data = pandas.read_csv(sGuard_contract_info_file_path_name)
   contracts_info=[]
   for index, row in df_data.iterrows():
       # solidity_file_name = row[0]
       # contract_name = row[2]
       # solc_version = row[1]
       contracts_info.append([row[0],row[2],row[1]])

   # prepare for the data necessary to construct environment
   parepare_contract_data_for_env_creation_0(result_file_name_and_path, contracts_info,f'{rl_result_path}{contract_rw_data}')


   # # ======================================
   """
   only for examining data after the contracts are grouped
   """
   # # only for examine data after the contracts are grouped
   # contracts_data = load_a_json_file(f'{rl_result_path}{contract_data_for_env_construction}')
   # contract_function_to_int_by_svar_func, contract_by_svar_func, contract_possible_targets = group_contracts_map_functions_1(
   #      contracts_data)
   #
   # counts={}
   # for key, value in contract_function_to_int_by_svar_func.items():
   #     num_function=len(value['function_to_int'].keys())
   #     if num_function in counts.keys():
   #         counts[num_function]+=1
   #     else:
   #         counts[num_function]=1
   # max=0
   # print(f'number of group functions: the number of groups:')
   # for k,v in counts.items():
   #     print(f'{k}:{v}')
   #     if k>max:
   #          max=k
   # print(f'max number of functions in a group:{max}')



   # # ***********************************************************
   """
   5, map functions to integers and different vector presentations
   """
   if not os.path.exists(rl_result_path + contract_data_for_env_construction):
       contracts_data = load_a_json_file( f'{rl_result_path}{contract_data_for_env_construction}')
       contracts_having_no_targets_2 = update_contract_data_in_integer_1(contracts_data)





   # # ***********************************************************
   """
   6, classify contracts: training and testing sets
   """
   update_contract_data = load_a_json_file(f'{rl_result_path}{contract_data_for_env_construction_in_integer}')
   def get_info_about_values():
       # ===========================
       max_svar_integer = 0
       max_func_element_value = 0
       for con_key, con_data in update_contract_data.items():
           if 'state_variables_in_integer' in con_data.keys():
               for svar_integer in con_data['state_variables_in_integer']:
                   if svar_integer > max_svar_integer:
                       max_svar_integer = svar_integer
           if 'function_value' in con_data.keys():
               for value in con_data['function_value']:
                   if value > max_func_element_value:
                       max_func_element_value = value

       print(f'max_svar_integer:{max_svar_integer}')
       print(f'max_func_element_value:{max_func_element_value}')
       # max_svar_integer:5729
       # max_func_element_value:64
   get_info_about_values()

   # divide based on 70/30
   contracts=[item for item in update_contract_data if '.sol' in item]
   indices=range(len(contracts))
   num_select=480
   seed=100
   random.seed(seed)
   selected=random.sample(indices, num_select)

   test_30p=[contracts[idx] for idx in selected]
   train_70p=[contracts[idx] for idx in indices if idx not in selected]


   print(f'{dataset}_train_70p:')
   print(f'{[f"{item}" for item in train_70p]}')
   print(f'{dataset}_test_30p:')
   print(f'{[f"{item}" for item in test_30p]}')

   # devide based on groups
   dataset_train,dataset_test=divide_contracts(update_contract_data)
   print(f'"{dataset}_train":')
   print(f'{[f"{item}" for item in dataset_train]}')
   print(f'"{dataset}_test":')
   print(f'{[f"{item}" for item in dataset_test]}')

   # 400,1198
   # 1108, 490
   # 24:40

   print(f'xx')





