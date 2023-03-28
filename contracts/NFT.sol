// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC165.sol";

interface IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface IERC721Metadata {
    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string memory _tokenURI);
}

contract NFT is IERC721, IERC721Metadata, IERC165 {
    mapping (uint256=>address) private owners;
    mapping (address=>uint256) private balances;
    mapping (uint256=>address) private tokenApprovals;
    mapping (address=> mapping(address=>bool)) private operatorApprovals;

    mapping (uint256=>string) public tokenURI;

    string public _name;
    string public _symbol; 
    string public _baseURI;

    constructor(string memory name_, string memory symbol_, string memory baseURI_){
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
    }

    function balanceOf(address _owner) external view returns (uint256){
        return balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address){
        return _ownerOf(_tokenId);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return operatorApprovals[_owner][_operator];
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address){
        return owners[_tokenId];
    }

    function name() external view returns (string memory){
        return _name;
    }

    function symbol() external view returns (string memory){
        return _symbol;
    }

    function getApproved(uint256 _tokenId) public view returns (address){
        return tokenApprovals[_tokenId];
    }

    function supportsInterface(bytes4 interfaceID) external pure returns(bool){
        return (
            interfaceID == this.balanceOf.selector
                            ^ this.ownerOf.selector
                            ^ bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"))
                            ^ bytes4(keccak256("safeTransferFrom(address,address,uint256)"))
                            ^ this.transferFrom.selector
                            ^ this.approve.selector
                            ^ this.setApprovalForAll.selector
                            ^ this.getApproved.selector
                            ^ this.isApprovedForAll.selector
        );
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function _isApprovalOrOwner(address _sender, uint256 _tokenId) internal view returns(bool){
        address owner = _ownerOf(_tokenId);
        return _sender == owner || getApproved(_tokenId) == _sender ||isApprovedForAll(owner, _sender);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public payable{
        require(_isApprovalOrOwner(msg.sender, _tokenId), "ERC721: Invalid Caller");
        require(_to != address(0), "ERC721: transfer to invalid Account" );

        _transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable{
        require(_isApprovalOrOwner(msg.sender, _tokenId), "ERC721: Invalid Caller");
        require(_to != address(0), "ERC721: transfer to invalid Account" );
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable{
        address owner = _ownerOf(_tokenId);
        require(_isApprovalOrOwner(msg.sender, _tokenId), "ERC721: Invalid Caller");

        tokenApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function mint(address _to, uint256 _tokenId) external {
        require(owners[_tokenId] == address(0));
        owners[_tokenId] = _to;
        balances[_to] += 1;

        emit Transfer(msg.sender, _to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external{
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        owners[_tokenId] = _to;

        delete tokenApprovals[_tokenId];

        balances[_from] -= 1;
        balances[_to] += 1;

        emit Transfer(_from, _to, _tokenId);
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) internal {
        tokenURI[_tokenId] = _tokenURI;
    }

}