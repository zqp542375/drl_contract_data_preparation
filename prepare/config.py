
project_path="C:\\Users\\18178\\PycharmProjects\\drl_contract_data_preparation\\"

dataset_path= project_path+"datasets\\"
result_path= project_path+"results\\"
dataset_contract_info_path= dataset_path+"contract_info\\"
dataset_solidity_path= dataset_path+"solidity_files\\"
contract_data_path= dataset_path+"contract_data\\"
task_data_path= dataset_path+"contract_task_data\\"
rl_contracts_data_path= dataset_path+"rl_contracts\\"



# ==================================================
# configuration for collecting contract data for small dataset
# ==================================================
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




# # ==================================================
# # configuration for collecting contract data for sGuard dataset
# # ==================================================
# NUM_actions=2
# NUM_state_variables=16
# MAX_svar_value=5740
# MAX_func_value_element=70
# rl_result_path = project_path + "results\\rl_related\\"
# contract_seq_collection_result_path=project_path+"sequence_from_SE\\24_rl_seq_collection_tacc_results\\"
# sGuard_contract_info_path_name =project_path+ "datasets\\sGuard_contracts\\sGuard_contracts_info.csv"
#
# solidity_path = "../datasets/sGuard_contracts/"
# dataset='sGuard'
# date="8_19_2024"
# contract_data=f"rl_{dataset}_contracts_data_{date}.json"
# contract_svar_data=f"rl_{dataset}_svar_info_{date}.json"
# contract_rw_data=f"rl_{dataset}_contracts_rw_data_{date}.json"
# contract_data_for_env_construction=f'rl_{dataset}_contracts_data_for_env_construction_{date}_{NUM_state_variables}.json'
# contract_data_for_env_construction_in_integer=f'rl_{dataset}_contracts_data_for_env_construction_{date}_{NUM_state_variables}_in_integer.json'
#
# contract_info_csv_file=f"rl_{dataset}_contracts_info_exp_{date}_svar.csv"






# ==================================================
color_prefix={
"Black": "\033[30m",
"Red": "\033[31m",
"Green": "\033[32m",
"Yellow": "\033[33m",
"Blue": "\033[34m",
"Magenta": "\033[35m",
"Cyan": "\033[36m",
"White": "\033[37m",
"Gray": "\033[0m",
}