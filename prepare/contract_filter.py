
def find_contracts(contract_function_rw:dict,least_num_functions:int=3):
   """
   find contracts that there at least "least_num_functions" functions write state variables.
   :param contract_function_rw:
   :param least_num_functions:
   :return:
   """
   contracts_find = []
   for con_key, function_data in contract_function_rw.items():
      # if con_key in ['0x000000000019fff0e5b945e90ee1e606aa22c6c2.solDaiBackstopSyndicateV2']:
      #    print(f'xs')
      func_count = 0
      for func, info in function_data.items():
         if func in ['constructor']: continue
         if 'writes' not in info.keys():continue
         if len(info['writes']) >= 1:
            func_count += 1
         if func_count >= least_num_functions:
            contracts_find.append(con_key)
            break
   return contracts_find

def digitalize_svar(contracts_found:list, contract_svar_info:dict):
   """
   for a given set of contracts: contract_found for example:
      - collect all the state variables from the contracts
      - organize state variables by the types of state variables
      - map all state variables to integers (same names of different types are mapped to different values)

   :param contracts_found:
   :param contract_svar_info:
   :return:
   """
   svar_by_type = {}
   for con_key in contracts_found:
      svar_info = contract_svar_info[con_key]
      for name, info in svar_info.items():
         tp = info['type']
         if tp not in svar_by_type.keys():
            svar_by_type[tp] = [name]
         else:
            if name not in svar_by_type[tp]:
               svar_by_type[tp].append(name)
   # for tp,v in svar_by_type.items():
   #    print(f'{tp}:{len(v)}')
   #    print(v)
   # svar_type=[[tp,v] for tp,v in svar_by_type.items()]
   # svar_type_sorted=sorted(svar_type,key=lambda x:len(x[1]), reverse=True)
   # for item in svar_type_sorted:
   #    print(f'{item}')
   # map state variable names to integers
   type_order=['uint256',  'address','bool', 'uintSmall','int', 'bytesFixed','mapping1','mapping2',  'mapping3',  'array_uint256', 'array_address',  'array_bool', 'array_uintSmall', 'array_bytesFixed', 'array1', 'array3','array_extra', 'bytes','string','userDefined']
   idx=0
   svar_to_int={}
   int_to_svar={}
   for tp in type_order:
      if tp not in svar_by_type.keys(): continue
      for svar in svar_by_type[tp]:
         if f'{svar},{tp}' not in svar_to_int.keys():
            idx += 1
            svar_to_int[f'{svar},{tp}']=idx
            int_to_svar[idx]=f'{svar},{tp}'
   return svar_by_type,svar_to_int,int_to_svar

def digitalize_found_contracts(found_contracts: list,
                               contract_function_r_w: dict,
                               contract_svar_info: dict, svar_to_int: dict):
   """
   for the given set of contracts, use integers to present:
      - the state variables
      - the state variables read and written by functions

   :param found_contracts:
   :param contract_function_r_w:
   :param contract_svar_info:
   :param svar_to_int:
   :return:
   """
   found_contract_data_in_int = {}
   for con_key in found_contracts:
      # if con_key in ['0x000000000019fff0e5b945e90ee1e606aa22c6c2.solDaiBackstopSyndicateV2']:
      #    print(f'xs')
      # find the int value for each state variable
      svar_int = {}
      int_svar = {}
      svar_info = contract_svar_info[con_key]
      for svar, info in svar_info.items():
         # if svar in ['_balances']:
         #    print(f'xx')
         svar_int[svar] = svar_to_int[f'{svar},{info["type"]}']
         int_svar[svar_to_int[f'{svar},{info["type"]}']] = svar

      function_data = contract_function_r_w[con_key]
      function_data_in_int = {}
      for func, info in function_data.items():
         function_data_in_int[func] = {key: [svar_int[v] for v in value] for
                                       key, value in info.items()}

      found_contract_data_in_int[con_key] = {
         "svar_info": svar_info,
         "svar_to_int": svar_int,
         "int_to_svar": int_svar,
         "function_data": function_data,
         "function_data_in_int": function_data_in_int

      }
   return found_contract_data_in_int

