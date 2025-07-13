// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VCRegistry {
    struct VCRecord {
        address issuer;
        string ipfsHash;
        bool revoked;
        uint256 issuedAt;
    }

    mapping(bytes32 => VCRecord) public vcs;

    event VCIssued(bytes32 indexed vcId, address indexed issuer, string ipfsHash);
    event VCRevoked(bytes32 indexed vcId);

    function issueVC(bytes32 vcId, string calldata ipfsHash) external {
        require(vcs[vcId].issuedAt == 0, "VC already issued");
        vcs[vcId] = VCRecord({
            issuer: msg.sender,
            ipfsHash: ipfsHash,
            revoked: false,
            issuedAt: block.timestamp
        });
        emit VCIssued(vcId, msg.sender, ipfsHash);
    }

    function revokeVC(bytes32 vcId) external {
        VCRecord storage record = vcs[vcId];
        require(record.issuedAt != 0, "VC not issued");
        require(record.issuer == msg.sender, "Only issuer can revoke");
        record.revoked = true;
        emit VCRevoked(vcId);
    }

    function isRevoked(bytes32 vcId) external view returns (bool) {
        return vcs[vcId].revoked;
    }
}
