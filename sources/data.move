module health_data_incentives::health_data_incentives {
    use std::signer;
    use aptos_framework::account;
    use std::vector;
    use aptos_framework::managed_coin;
    use aptos_framework::coin;
    use aptos_std::type_info;
    use aptos_std::simple_map::{Self, SimpleMap};

    // Health data struct
    struct HealthData has key, store {
        id: u64,
        user: address,
        data_type: vector<u8>, // e.g. "steps", "sleep", "nutrition"
        data: vector<u8>, // e.g. JSON-encoded data
        timestamp: u64,
    }

    // Incentive struct
    struct Incentive has key, store {
        id: u64,
        name: vector<u8>,
        description: vector<u8>,
        reward: u64, // amount of tokens to reward
        criteria: vector<u8>, // e.g. "10000 steps in a day"
    }

    // Health data incentives platform struct
    struct HealthDataIncentivesPlatform has key, store {
        health_data: SimpleMap<address, vector<HealthData>>,
        incentives: SimpleMap<u64, Incentive>,
        user_rewards: SimpleMap<address, u64>,
    }

    // Initialize the health data incentives platform
   public entry fun init_platform(account: &signer) acquires HealthDataIncentivesPlatform {
        let account_addr = signer::address_of(account);
        if (!exists<HealthDataIncentivesPlatform>(account_addr)) {
            move_to(account, HealthDataIncentivesPlatform { health_data: simple_map::create(), incentives: simple_map::create(), user_rewards: simple_map::create() })
        }
    }

    // Add health data
    public entry fun add_health_data(account: &signer, data_type: vector<u8>, data: vector<u8>, timestamp: u64) acquires HealthDataIncentivesPlatform {
        let account_addr = signer::address_of(account);
        let platform = borrow_global_mut<HealthDataIncentivesPlatform>(account_addr);
        let health_data = HealthData { id: platform.health_data.len(), user: account_addr, data_type, data, timestamp };
        platform.health_data.push(health_data);
    }    
    // Create an incentive
      public entry fun create_incentive(account: &signer, name: vector<u8>, description: vector<u8>, reward: u64, criteria: vector<u8>) acquires HealthDataIncentivesPlatform {
     let account_addr = signer::address_of(account);
        let platform = borrow_global_mut<HealthDataIncentivesPlatform>(account_addr);
        let incentive = Incentive { id: platform.incentives.len(), name, description, reward, criteria };
        platform.incentives.push(incentive);
    }

    // Check if a user has met an incentive criteria
    public entry fun check_incentive(account: &signer, incentive_id: u64) acquires HealthDataIncentivesPlatform {
        let account_addr = signer::address_of(account);
        let platform = borrow_global_mut<HealthDataIncentivesPlatform>(account_addr);
        let incentive = simple_map::borrow(&platform.incentives, incentive_id);
        let health_data = simple_map::borrow(&platform.health_data, account_addr);
        // Check if the user has met the incentive criteria
        if (!user_met_criteria ){
           //  Reward the user
            let reward = incentive.reward;
            managed_coin::transfer(account_addr, reward);
            platform.user_rewards.insert(account_addr, reward);
            }
    }
}