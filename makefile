testnetICP:
	@echo "Starting local testnet..."
	dfx start --clean
newMinter:
	@echo "Creating new minter identity..."
	dfx identity new minter --storage-mode plaintext

checkMinter:
	@echo "Checking minter identity..."
	@echo "Minter principal: $(shell dfx identity get-principal)"

checkDefault:
	@echo "Checking default identity..."
	@echo "Default principal: $(shell dfx identity get-principal)"

setMinter:
	@echo "Switching to minter identity..."
	@dfx identity use minter
	@export MINTER=$$(dfx identity get-principal)
	@echo "Minter identity created and set. Minter principal: $(shell dfx identity get-principal)"

setDefault:
	@echo "Switching to default identity..."
	@dfx identity use default
	@export DEFAULT=$$(dfx identity get-principal)
	@echo "Default identity set. Default principal: $(shell dfx identity get-principal)"

deployIcrc1Ledger:
	dfx deploy icrc1_ledger_canister --specified-id mxzaz-hqaaa-aaaar-qaada-cai --argument "(\
	variant { Init = \
	record { \
		token_symbol = \"ICRC1\"; \
		token_name = \"L-ICRC1\"; \
		minting_account = record { owner = principal \"${MINTER}\" }; \
		transfer_fee = 10_000; \
		metadata = vec {}; \
		initial_balances = vec { record { record { owner = principal \"${DEFAULT}\"; }; 100_000_000_000; }; }; \
		archive_options = record { \
			num_blocks_to_archive = 1000; \
			trigger_threshold = 2000; \
			controller_id = principal \"${MINTER}\"; \
		}; \
	} \
	})"


deployInternetIdentity:
	@echo "Deploying Internet Identity..."
	dfx deploy internet_identity

deployBackend:
	@echo "Deploying backend..."
	dfx deploy icrc1_ledger_backend

transferTokens:
	dfx canister call icrc1_ledger_canister icrc1_transfer "(\
	record { \
		to = record { \
			owner = principal \"$$(dfx canister id icrc1_ledger_backend)\"; \
		}; \
		amount = 10_000_000_000; \
	})"
	@echo "Tokens transferred to backend."
	dfx canister call icrc1_ledger_canister icrc1_balance_of "(\
	record { \
		owner = principal \"${DEFAULT}\"; \
	})"