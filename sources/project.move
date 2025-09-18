module MyModule::RandomizedNFTGenerator {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::string::{Self, String};
    use std::vector;

    /// Struct representing an NFT with randomized attributes
    struct NFT has store, key {
        id: u64,           // Unique NFT identifier
        name: String,      // NFT name
        rarity: u8,        // Rarity level (1-5, where 5 is rarest)
        attribute: String, // Random attribute (color, element, etc.)
    }

    /// Struct to track NFT generation for an account
    struct NFTCollection has store, key {
        next_id: u64,      // Counter for next NFT ID
        total_minted: u64, // Total NFTs minted by this account
    }

    /// Function to initialize NFT collection for a user
    public fun initialize_collection(owner: &signer) {
        let collection = NFTCollection {
            next_id: 1,
            total_minted: 0,
        };
        move_to(owner, collection);
    }

    /// Function to generate a randomized NFT
    public fun mint_random_nft(owner: &signer) acquires NFTCollection {
        let owner_addr = signer::address_of(owner);
        
        // Get or initialize collection
        if (!exists<NFTCollection>(owner_addr)) {
            initialize_collection(owner);
        };
        
        let collection = borrow_global_mut<NFTCollection>(owner_addr);
        
        // Generate pseudo-random values using timestamp and counter
        let current_time = timestamp::now_microseconds();
        let seed = current_time + collection.next_id;
        
        // Generate random rarity (1-5)
        let rarity = ((seed % 100) / 20) + 1;
        
        // Generate random attribute based on seed
        let attributes = vector[
            string::utf8(b"Fire"), string::utf8(b"Water"), string::utf8(b"Earth"), 
            string::utf8(b"Air"), string::utf8(b"Light"), string::utf8(b"Dark")
        ];
        let attribute_index = (seed / 7) % vector::length(&attributes);
        let selected_attribute = *vector::borrow(&attributes, attribute_index);
        
        // Create NFT name
        let nft_name = string::utf8(b"RandomNFT #");
        string::append(&mut nft_name, u64_to_string(collection.next_id));
        
        // Create the NFT
        let nft = NFT {
            id: collection.next_id,
            name: nft_name,
            rarity: (rarity as u8),
            attribute: selected_attribute,
        };
        
        // Update collection counters
        collection.next_id = collection.next_id + 1;
        collection.total_minted = collection.total_minted + 1;
        
        // Store NFT (in practice, you'd want a better storage mechanism)
        move_to(owner, nft);
    }

    /// Helper function to convert u64 to string (simplified)
    fun u64_to_string(num: u64): String {
        if (num == 0) return string::utf8(b"0");
        let result = vector::empty<u8>();
        let temp = num;
        while (temp > 0) {
            let digit = ((temp % 10) as u8) + 48; // Convert to ASCII
            vector::push_back(&mut result, digit);
            temp = temp / 10;
        };
        vector::reverse(&mut result);
        string::utf8(result)
    }
}