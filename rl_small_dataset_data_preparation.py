"""
Get RW data for small dataset.
Prepare for rw data for my reinforcement learning project
constructor: reads:[], writes:[initialized state variables and those read in constructors]
   collect rw data
"""
import os.path
from prepare.config import project_path
from prepare.contract_filter import digitalize_found_contracts, digitalize_svar, \
   find_contracts
from prepare.prepare_env_data import find_file_names_and_paths, \
    parepare_contract_data_for_env_creation_0
from prepare.static_data_collection import collect_svar_slither, \
   collect_rw_data_slither
from prepare.contract_train_test import update_contract_data_in_integer, divide_contracts
from prepare.utils import load_a_json_file,  dump_json_object_to_json


# ==================================================
# collect contract data for small dataset

NUM_state_variables=8
MAX_svar_value=80
MAX_func_value_element=30
rl_result_path = project_path + "results\\rl_related\\"
contract_seq_collection_result_path=project_path+"sequence_from_SE\\24_rl_seq_collection_small_dataset_manual\\"
solidity_path = "../datasets/rl_contracts/"
dataset = "small_dataset"
date = "8_19_2024"
contract_data=f"rl_{dataset}_contracts_data_{date}.json"
contract_svar_data=f"rl_{dataset}_svar_info_{date}.json"
contract_rw_data=f"rl_{dataset}_contracts_rw_data_{date}.json"
contract_data_for_env_construction=f'rl_{dataset}_contracts_data_for_env_construction_{date}_{NUM_state_variables}.json'
contract_data_for_env_construction_in_integer=f'rl_{dataset}_contracts_data_for_env_construction_{date}_{NUM_state_variables}_in_integer.json'

# contracts in small dataset
contracts_info_small_dataset = [
    ['HoloToken.sol', 'HoloToken', '0.4.18'],
    ['HoloToken_test_01.sol', 'HoloToken_test_01', '0.4.18'],
    ["HoloToken_test_02.sol", "HoloToken_test_02", "0.4.18"],
    ["Crowdsale.sol", "Crowdsale", "0.4.25"],
    ["0x2f47f03b03946b1fe11d841744217db881d4f531.sol", "BulkSender",
     "0.6.4"],
    ["0x89f9749ce943281b8c65fec7f15e126f8cf4edb1.sol", "DepositGame",
     "0.4.25"],
    ["0xa143fd004b3c26f8faedeb9224ec03585e63d041.sol",
     "DharmaSpreadRegistryPrototypeStaging", "0.5.11"],
    ["0xce4763c7fa2e1238a398c0b07a9abf6472531d51.sol", "BHT", "0.4.26"],
    ["0xd75b02dc969182fd9a8cbc4f12f3502c61802747.sol", "EtherBoxLevels",
     "0.5.13"],
    ["0x60accbD43E9aAd281c1CDe56D3F5ed697B948b22.sol", "sproof", "0.5.9"],
    ["0xed39480b5bcd7c123f374b3b37366f60bc5d50e1.sol", "TimelockGovernance",
     "0.5.16"],
    ["0xc0ea83113038987d974fe667831a36e442e661e7.sol", "LibfxToken",
     "0.5.11"],
    ["0xad638296f8348a9d72d5fbecd7b7d941d2889083.sol", "EternalStorage",
     "0.5.0"],
    ["0x8382ADf670cb280F2f318bC2446be3860758aEF4.sol", "GramChain",
     "0.5.13"],
    ["0x3422ac57f4ca097806fa234e44ec0a781b78bbdb.sol", "YFVReferral",
     "0.5.0"],
    ["0x131f983da6fabf20869f5ace3516a23f28b46204.sol", "Blacklist",
     "0.5.2"],
    ["0x46d52bace05457929e1cd84c9efcee0d2156555b.sol",
     "SimpleWriteAccessController", "0.6.0"],
    ["0x7C6664bd7957eD63f8fbF635101A186741Ef14D4.sol",
     "AdministratorMinter", "0.5.0"],
    ["0x4b205ad9e4a2669cf9428c1a5f72ca17976f0167.sol", "MonetaGiftBox",
     "0.6.6"],
    ["0xbb86cd4c05c321015078433863fd203a61560fcb.sol",
     "Gruppa_Istoricheskiy_Roman", "0.5.0"],

    ["HoloToken_test_03.sol", "HoloToken_test_03", "0.4.18"],
    ["Crowdsale_rlf.sol", "Crowdsale", "0.4.25"],
    ["Crowdsale_01.sol", "Crowdsale", "0.4.25"],
    ["0xdb25ff2868cbc48856e44a2ae8e2f2b62f1f3b84.sol", "BulkSender",
     "0.6.4"],
    ["0xe4ea2d60783fc54c3595bda39ac1ab6556723d38.sol", "BHE", "0.4.26"],
    ["0x87c48b167bb02cc88487ce6dc12f5e56cd49676a.sol", "TimelockGovernance",
     "0.5.16"],
    ["0x316Fe7d9610F56Aff59B8Db695dF625581Eb3B4A.sol", "CYT", "0.5.11"],
    ["0x00111feeb7ee43e262ff38aaf912b72ea668edc3.sol", "RipgaleToken",
     "0.5.11"],
    ["0x29d9ede1d2fac6fe3b19d6005a81540d094665a5.sol", "Blacklist",
     "0.5.2"],
    ["0x4e8c0598ef8c3d44967bd4fa101c54939ab97d53.sol", "Blacklist",
     "0.5.2"],
    ["0x283d2d5fa7ec80f00bfeeb370e1b8cbf7caba614.sol", "YAMToken",
     "0.5.11"],
]

if __name__=="__main__":

   svar_by_type={}
   contract_function_r_w={}
   contract_svar={}

   #***********************************************************
   """
   # 1, collect rw data using Slither
   """

   print(f'contract_data{contract_data}')
   if not os.path.exists(rl_result_path+ contract_data):
       contract_svar,svar_by_type,contract_function_r_w=collect_rw_data_slither(solidity_path,contracts_info_small_dataset )

       rl_contract_data={'contract_svar':contract_svar,'svar_by_type':svar_by_type,'contract_function_r_w':contract_function_r_w}

       dump_json_object_to_json(rl_contract_data, rl_result_path+ contract_data)





   #***********************************************************
   """
   # 2, collect svar info
   """
   if not os.path.exists(rl_result_path + contract_svar_data):
       contract_svar_info=collect_svar_slither(solidity_path,contracts_info_small_dataset)

       dump_json_object_to_json(contract_svar_info,
                                rl_result_path + contract_svar_data)


   #***********************************************************
   """
   # 3, collect required contracts: at least m functions that can write state variables (not constant)
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


   #***********************************************************
   """
   # 4, get the result file names and their paths (function sequences from symbolic execution)
   """
   result_file_name_and_path = find_file_names_and_paths(contract_seq_collection_result_path)

   # ***********************************************************
   # ========================
   # 5, prepare for the data necessary to construct environment
   # ========================

   parepare_contract_data_for_env_creation_0(result_file_name_and_path, contracts_info_small_dataset,f'{rl_result_path}{contract_rw_data}')




   # ***********************************************************
   """
     6, map functions to integers and different vector presentations
      classify contracts: training and testing sets
   """


   contracts_data = load_a_json_file( f'{rl_result_path}{contract_data_for_env_construction}')
   contracts_having_no_targets_2 = update_contract_data_in_integer(contracts_data)
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

   get_info_about_values()


   small_dataset_train,small_dataset_test=divide_contracts(update_contract_data)

   print(f'"small_dataset_train_1":')
   print(f'{[f"{item}" for item in small_dataset_train]}')

   print(f'"small_dataset_test_1":')
   print(f'{[f"{item}" for item in small_dataset_test]}')

   print(f'xx')
   # 28(20,8)