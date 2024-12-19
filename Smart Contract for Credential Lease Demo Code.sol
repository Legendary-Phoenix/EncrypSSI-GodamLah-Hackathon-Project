// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CredentialLeasing {
    struct Lease {
        uint256 leaseID;        // Unique identifier for the lease
        address ownerDID;       // Owner's DID
        address lesseeDID;      // Lessee's DID
        string vcID;            // Identifier of the Verifiable Credential
        uint256 expiration;     // Lease expiration timestamp
        bool revoked;           // Whether the lease has been revoked
    }

    mapping(string => Lease) public leases; // Map leaseID to Lease struct

    event LeaseCreated(
        uint256 leaseID,
        address indexed ownerDID,
        address indexed lesseeDID,
        string vcIdentifier,
        uint256 expiration
    );

    event LeaseRevoked(uint256 leaseID, address indexed ownerDID);


    // Create a new lease
    function createLease(
        string memory leaseID,
        address lessee,
        string memory vcID,
        uint256 expiration
    ) public {
        require(leases[leaseID].owner == address(0), "Lease already exists");
        require(expiration > block.timestamp, "Invalid expiration time");

        leases[leaseID] = Lease({
            owner: msg.sender,
            lessee: lessee,
            vcID: vcID,
            expiration: expiration,
            revoked: false
        });
    }

    // Revoke an existing lease
    function revokeLease(string memory leaseID) public {
        require(leases[leaseID].owner == msg.sender, "Not the owner");
        require(!leases[leaseID].revoked, "Lease already revoked");

        leases[leaseID].revoked = true;
    }

    // Validate the lease for a given lessee
    function validateLease(string memory leaseID, address lessee) public view returns (bool) {
        Lease memory lease = leases[leaseID];
        if (
            lease.revoked ||                          // Check if revoked
            lease.expiration <= block.timestamp ||    // Check expiration
            lease.lessee != lessee                    // Check lessee match
        ) {
            return false;
        }
        return true;
    }
}
