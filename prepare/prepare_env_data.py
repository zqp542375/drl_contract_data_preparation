"""
July 4th,2024
re-organize contracts manually collected based on the way to deal with sGuard dataset
"""

import ast
import os
from copy import deepcopy

import pandas

from prepare.config import NUM_state_variables, dataset, rl_result_path, \
    date, contract_data_for_env_construction
from prepare.utils import dump_json_object_to_json, load_a_json_file


class EnvDataCollection02():
    """
    prepare for the data needed to create environments
        static analysis data
        arg1 (a list of files): file containing the data resulted from the symbolic execution


    """

    def __init__(self, solidity_file_name: str, contract_name: str,
                 files_of_se_data: list):

        self.solidity_file_name = solidity_file_name
        self.contract_name = contract_name

        self.file_paths_for_se_data = files_of_se_data

        self.targets = []
        self.start_functions = []
        self.functions_in_sequences = []  # get the function appearing in sequences
        self.function_sequence_writes = {}

        self.state_variables = []
        self.state_variables_in_integer = []

        self.function_reads_writes = {}
        self.function_sequence_writes = {}
        self.function_reads_writes_in_integer = {}

    def init(self):
        self.get_execution_data(self.file_paths_for_se_data)

        self.get_functions_in_sequences()

    def get_execution_data(self, file_paths: [str]):
        def get_key_from_list(data_list: list) -> str:
            if len(data_list) == 0:
                return ''
            else:
                key = data_list[0]
                for item in data_list[1:]:
                    key += "#" + item
                return key

        for file_path in file_paths:
            flag_reads = False
            flag_writes = False
            flag_start_function = False
            with open(file_path) as file:
                for line in file:
                    line = line.strip()
                    if len(line) == 0: continue
                    # print(f'{line}')
                    if ":writes at the last depth:" in line:
                        items = line.split(":")
                        seq = ast.literal_eval(items[0])

                        seq_ = [func.split(f'(')[0] if '(' in func else func for
                                func in seq]

                        writes = ast.literal_eval(items[-1])
                        seq_key = get_key_from_list(seq_)

                        writes_int = [int(ele) for ele in writes if
                                      len(ele) > 0]
                        if seq_key not in self.function_sequence_writes.keys():
                            self.function_sequence_writes[seq_key] = writes_int
                        else:
                            for w in writes_int:
                                if w not in self.function_sequence_writes[
                                    seq_key]:
                                    self.function_sequence_writes[
                                        seq_key].append(w)
                        if flag_start_function:
                            if seq_[0] not in self.start_functions:
                                self.start_functions.append(seq_[0])

                        continue
                    else:
                        if "targets:[" in line:
                            targets = ast.literal_eval(
                                line.split('targets:')[-1])
                            for t in targets:
                                t_ = t.split(f'(')[0] if '(' in t else t
                                if t_ not in self.targets:
                                    self.targets.append(t_)
                            continue

                        elif "Function Reads: State variables read in conditions" in line:
                            flag_reads = True
                            flag_writes = False
                            continue
                        elif "Function Writes: State variables written" in line:
                            flag_reads = False
                            flag_writes = True
                            continue
                        elif "iteration:3" in line:
                            flag_reads = flag_writes = False
                            flag_start_function = True
                            continue
                        elif "iteration:4" in line:

                            flag_start_function = False
                            continue
                    if "=====================" in line: continue
                    # get the state variables read in conditions
                    if flag_reads:
                        items = line.split(':')
                        try:
                            reads = ast.literal_eval(items[-1])
                            reads = [int(read) for read in reads]
                            if items[0] not in self.function_reads_writes.keys():
                                self.function_reads_writes[items[0]] = {
                                    'reads': reads}
                            else:
                                for read in reads:
                                    if read not in \
                                            self.function_reads_writes[items[0]][
                                                'reads']:
                                        self.function_reads_writes[items[0]][
                                            'reads'].append(read)
                        except:
                            pass
                    # get the state variables written
                    if flag_writes:
                        items = line.split(':')
                        try:
                            writes = ast.literal_eval(items[-1])
                            writes = [int(write) for write in writes]
                            if items[0] not in self.function_reads_writes.keys():
                                self.function_reads_writes[items[0]] = {
                                    'writes': writes}
                            else:
                                if 'writes' not in self.function_reads_writes[
                                    items[0]].keys():
                                    self.function_reads_writes[items[0]][
                                        'writes'] = writes
                                else:
                                    for write in writes:
                                        if write not in \
                                                self.function_reads_writes[
                                                    items[0]][
                                                    'writes']:
                                            self.function_reads_writes[items[0]][
                                                'writes'].append(write)
                        except:
                            pass

        print(f'start function: {self.start_functions}')
        print(f'target function: {self.targets}')
        # for func, value in self.function_sequence_writes.items():
        #     print(f'{func}:{value}')

    def get_functions_in_sequences(self):
        def get_seq_from_key(key: str):
            if '#' in key:
                return key.split("#")
            else:
                return [key]

        for key in self.function_sequence_writes.keys():
            key_seq = get_seq_from_key(key)
            for func in key_seq:
                if func not in self.functions_in_sequences:
                    self.functions_in_sequences.append(func)

    def receive_data_from_static_analysis(self, static_analysis_data: dict):
        key = f'{self.solidity_file_name}{self.contract_name}'

        # if key in ['0x000000000019fff0e5b945e90ee1e606aa22c6c2.solDaiBackstopSyndicateV2']:
        #    print(f'xs')

        if key not in static_analysis_data["found_contract_data_in_int"].keys():
            print(f'{key} does not has static analysis data.')
        else:

            contract_data=static_analysis_data['found_contract_data_in_int'][key]
            self.state_variables = list(contract_data['svar_to_int'].keys())
            self.state_variables_in_integer = list(contract_data['int_to_svar'].keys())
            self.state_variables_in_integer=[int(svar) if isinstance(svar,str) else svar for svar in self.state_variables_in_integer]
            self.function_reads_writes = contract_data["function_data"]

            self.function_reads_writes_in_integer = contract_data["function_data_in_int"]
            # print(f'\n function reads and writes from static analysis')
            # for k, v in self.function_reads_writes.items():
            #     print(f'{k}:{v}')
            # print(f'\n function reads and writes(integers) from static analysis')
            # for k, v in self.function_reads_writes_in_integer.items():
            #     print(f'{k}:{v}')


class CollectContractEnvData_wsa():
    """
    use the static analysis data to collect the required data


    """

    def __init__(self, envDataCollected: EnvDataCollection02,
                 num_state_var: int = 8, num_reads: int = 3,
                 num_writes: int = 3):

        self.envDataCollected = envDataCollected
        self.num_state_var = num_state_var
        self.num_reads = num_reads
        self.num_writes = num_writes

        self.state_variables_in_integer = sorted(
            self.envDataCollected.state_variables_in_integer)
        self.selected_svar = []

        self.function_data = {}  # the keys, names, and vectors of functions
        self.function_value = []
        self.function_value_n0 = []

    def get_functions_r_w_in_index(self):
        """
        use the indices to represent the state variables read/written by each function

        """

        if len(self.state_variables_in_integer) > self.num_state_var:
            self.selected_svar = self.state_variables_in_integer[
                                 0:self.num_state_var]
        else:
            self.selected_svar = self.state_variables_in_integer + [0] * (
                        self.num_state_var - len(
                    self.state_variables_in_integer))

        func_read_write_in_index = {}

        for func in self.envDataCollected.function_reads_writes_in_integer.keys():
            r_w_info = self.envDataCollected.function_reads_writes_in_integer[
                func]

            read_int = []
            if "reads" in r_w_info.keys():
                read_int = deepcopy(r_w_info["reads"])

            write_int = []
            if "writes" in r_w_info.keys():
                write_int = deepcopy(r_w_info["writes"])

            if len(read_int) == 0 and len(write_int) == 0:
                continue

            if len(read_int) > self.num_reads:
                read_int = sorted(read_int, reverse=False)
                read_int = read_int[0:self.num_reads]
            elif len(read_int) < self.num_reads:
                read_int += [-1] * (self.num_reads - len(read_int))

            if len(write_int) > self.num_writes:
                write_int = sorted(write_int, reverse=False)
                write_int = write_int[0:self.num_writes]
            elif len(write_int) < self.num_writes:
                write_int += [-1] * (self.num_writes - len(write_int))

            read_indices = [1 if svar in read_int else 0 for svar in
                            self.selected_svar]
            write_indices = [1 if svar in write_int else 0 for svar in
                             self.selected_svar]
            func_read_write_in_index[func] = {"reads": read_indices,
                                              'writes': write_indices}

            # if func in ['BHT.contTransfer(address,uint256)','BHE.contTransfer(address,uint256)']:
            #     print(f'---------------')
            #     print(f'self.selected_svar:{self.selected_svar}')
            #     print(f'read_int:{read_int}')
            #     print(f'read_indices:{read_indices}')
            #     print(f'write_indices:{write_indices}')

        return func_read_write_in_index

    def collect_function_data(self):
        func_read_write_in_index_vector = self.get_functions_r_w_in_index()

        # combine read vectors and write vectors
        func_rw_in_index = {key: [e1 * 2 + e2 for e1, e2 in
                                  zip(value['reads'], value['writes'])] for
                            key, value in
                            func_read_write_in_index_vector.items()}

        self.function_value = [0] * self.num_state_var
        for k, value in func_rw_in_index.items():
            # print(f'\t{value}:{k}')
            self.function_value = [e1 + e2 for e1, e2 in
                                   zip(self.function_value, value)]

            # print(f'self.function_value:{self.function_value}')

        self.function_value_n0 = [0] * self.num_state_var
        for k, value in func_rw_in_index.items():
            if k not in ['constructor', 'constructor()']:
                # print(f'\t{value}:{k}')
                self.function_value_n0 = [e1 + e2 for e1, e2 in
                                          zip(self.function_value_n0, value)]

                # print(f'self.function_value_n0:{self.function_value_n0}')
        # func_rw_data=[[key, value] for key,value in func_rw_in_index.items()]
        # sorted_func_rw_data=sort_lists(func_rw_data,index=1)

        for name, comb_rw_vector_in_index in func_rw_in_index.items():

            reads = \
            self.envDataCollected.function_reads_writes_in_integer[name][
                'reads']
            writes = \
            self.envDataCollected.function_reads_writes_in_integer[name][
                'writes']

            reads = sorted(reads, reverse=False)
            writes = sorted(writes, reverse=False)
            # from comb_rw_in_idx_new to get reads and writes and the last element used to distinguish functions with the same presentation

            reads_ = reads[0:self.num_reads] if len(reads) >= self.num_reads else reads + [0] * (
                        self.num_reads - len(reads))
            writes_ = writes[0:self.num_writes] if len(writes) >= self.num_writes else writes + [0] * (
                        self.num_writes - len(writes))

            func_rw_in_concate = reads_ + writes_

            if '(' in name:
                pure_name = name.split('(')[0]
            else:
                pure_name = name
            if '.' in pure_name:
                pure_name = pure_name.split('.')[-1]

            if name == 'constructor':

                self.function_data[name] = {'name': name,
                                            "pure_name": pure_name,
                                            "reads": reads,
                                            "writes": writes,
                                            "vector_in_index_rw": comb_rw_vector_in_index,
                                            # old: comb_rw_vector_in_index,
                                            "vector_rw_in_concate": func_rw_in_concate
                                            }

            else:

                self.function_data[name] = {'name': name,
                                            "pure_name": pure_name,
                                            "reads": reads,
                                            "writes": writes,
                                            "vector_in_index_rw": comb_rw_vector_in_index,
                                            "vector_rw_in_concate": func_rw_in_concate
                                            }

        if 'constructor' not in self.function_data.keys():
            self.function_data['constructor'] = {'name': "constructor()",
                                                 "pure_name": "constructor",
                                                 "reads": [],
                                                 "writes": [],
                                                 "vector_in_index_rw": [
                                                                           0] * self.num_state_var,
                                                 "vector_rw_in_concate": [0] * (
                                                             self.num_reads + self.num_writes)
                                                 }

    def obtain_contract_data(self):
        self.collect_function_data()
        data = {
            "state_variable": self.envDataCollected.state_variables,
            "state_variables_in_integer": self.state_variables_in_integer,
            "state_variables_selected": self.selected_svar,
            # select 8 state variables
            "function_value": self.function_value,
            "function_value_n0": self.function_value_n0,
            "function_data": self.function_data,
            "function_sequences": self.envDataCollected.function_sequence_writes,
            "functions_in_sequences": self.envDataCollected.functions_in_sequences,
            "target_functions": self.envDataCollected.targets,
            "start_functions": self.envDataCollected.start_functions
        }

        return data


def list_files(directory,extenion:str=".txt"):
    files = []
    for root, _, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(extenion):
                files.append(os.path.join(root, filename))
    return files

def find_file_names_and_paths(directory,extenion:str=".txt"):
    files_name_path = {}
    for root, _, filenames in os.walk(directory):
        for filename in filenames:
            if filename.endswith(extenion):
                if "collection" in filename or "collect" in filename:
                    files_name_path[filename]=root+f'\\'
                elif "smartExecutor" in filename:
                    files_name_path[filename]=root+f'\\'
    return files_name_path





def get_env_raw_data_0(solidity_file_name: str, contract_name: str, result_file_names:list,rw_data_json_file_path_name:str):
    env_data = None


    env_data = EnvDataCollection02(solidity_file_name, contract_name,
                                   result_file_names)
    env_data.init()
    static_data = load_a_json_file(rw_data_json_file_path_name)
    env_data.receive_data_from_static_analysis(static_data)

    return env_data


def parepare_contract_data_for_env_creation_0(result_files_name_and_path:dict, contract_info:list, rw_data_json_file_path_name:str):
    """

    :param result_files_name_and_path:
    :param contract_info:
    :param rw_data_json_file_path_name:
    :return:
    """
    contracts_data = {}
    contracts_having_no_start_functions=[]
    contracts_having_no_targets=[]

    for item in contract_info:

        solidity_file_name = item[0]
        contract_name = item[1]
        solc_version =item[2]

        file_name_prefix=f'{solidity_file_name}{contract_name}'
        file_name_prefix1=f'{solidity_file_name}__{contract_name}'
        file_path_and_names=[]
        for k,path in result_files_name_and_path.items():
            if file_name_prefix in k or file_name_prefix1 in k:
                file_path_and_names.append(path+k)

        if len(file_path_and_names)==0:
            continue


        # get env raw data
        env_data = get_env_raw_data_0(solidity_file_name,contract_name,file_path_and_names,rw_data_json_file_path_name)

        if len(env_data.start_functions)==0:
            contracts_having_no_start_functions.append([solidity_file_name,solc_version,contract_name])
        elif len(env_data.targets)==0:
            contracts_having_no_targets.append([solidity_file_name,solc_version,contract_name])
        else:

            conEnvData = CollectContractEnvData_wsa(env_data,num_state_var=NUM_state_variables)
            data = conEnvData.obtain_contract_data()
            key=f'{solidity_file_name}{contract_name}'
            if key not in contracts_data.keys():
                contracts_data[key] = data

    static_data = load_a_json_file(rw_data_json_file_path_name)
    contracts_data["svar_by_type"] = static_data['svar_by_type']
    contracts_data["svar_to_int"] = static_data['svar_to_int']
    contracts_data["int_to_svar"] = static_data['int_to_svar']
    dump_json_object_to_json(contracts_data,
                             f'{rl_result_path}{contract_data_for_env_construction}')

    df_no_start_functions=pandas.DataFrame(contracts_having_no_start_functions)
    df_no_start_functions.to_csv(f'{rl_result_path}{dataset}_contracts_having_no_start_functions_{date}_{NUM_state_variables}.csv',index=False)
    df_no_targets=pandas.DataFrame(contracts_having_no_targets)
    df_no_targets.to_csv(f'{rl_result_path}{dataset}_contracts_having_no_targets_{date}_{NUM_state_variables}.csv',index=False)

