pragma solidity = 0.8.11;

// interfaz de usurio
interface ZcopTokenReceiver {

  function onZcopReceived(
    address operator, address from, uint256 tokenId, bytes calldata data
  ) 
    external returns (bytes4);
}


//Contrato 
contract PARTYCIPATION {

  uint256 private constant _cap = 1;
  string private constant _name = "Z COP";

  // Token propio
  address private _owner;

  // The token's symbol.
  string private constant _symbol = unicode"@@kh";

  // Number of tokens minted.
  uint256 private _minted;

  // Emits when the approved addressed is changed or reaffirmed where
  // the zero address means there is no approved address.
  event Approval(
    address indexed owner, address indexed approved, uint256 indexed tokenId
  );

  // Emits when a third party is enabled or removed from managing all of
  // the owner's token(s).
  event ApprovalForAll(
    address indexed owner, address indexed operator, bool approved
  );

  // Emits when the token ownership changes.
  event Transfer(
    address indexed from, address indexed to, uint256 indexed tokenId
  );

  // Mapping from the owner's address to token count.
  mapping(address => uint256) private _balances;

  // Mapping from the owner to operator approvals.
  mapping(address => mapping(address => bool)) private _operatorApprovals;

  // Mapping from the token id to owner's address.
  mapping(uint256 => address) private _owners;

  // Contains all the interfaces supported by this contract as per

  mapping(bytes4 => bool) internal _supportedInterfaces;

  // Mapping from the token id to an approved address.
  mapping(uint256 => address) private _tokenApprovals;

  constructor() {
    _minted = 0;
    _owner = msg.sender;
    _supportedInterfaces[0x01ffc9a7] = true;  // ERC-165
    _supportedInterfaces[0x80ac58cd] = true;  // ERC-721
    _supportedInterfaces[0x5b5e139f] = true;  // ERC-721 Metadata
  }

  // Approves an address to operate on the token with the specified id.
  function _approve(address to, uint256 tokenId) private {
    _tokenApprovals[tokenId] = to;
    emit Approval(ownerOf(tokenId), to, tokenId);
  }

  // Calls ERC721Received on a target address if the target is not a
  // contract.
  function _checkOnZcopReceived(
    address from, address to, uint256 tokenId, bytes memory data
  ) 
    private returns (bool) 
  {
    if (_isContract(to)) {
      try ZcopTokenReceiver(to).onZcopReceived(
        msg.sender, from, tokenId, data
      ) 
        returns (bytes4 retval) 
      {
        return retval == ZcopTokenReceiver.onZcopReceived.selector;
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("client does not implement ZcopReceiver");
        } else {
          assembly { revert(add(32, reason), mload(reason)) }
        }
      }
    } else {
      return true;
    }
  }

  // Returns true if the spender is allowed to manage the token with the
  // specified id.
  function _isApprovedOrOwner(
    address spender, uint256 tokenId
  ) 
    private view returns (bool) 
  {
    require(_tokenExists(tokenId), "token does not exist");
    address owner = ownerOf(tokenId);
    return (spender == owner || getApproved(tokenId) == spender || 
      isApprovedForAll(owner, spender));
  }

  // Returns true of the account is a contract. 
  function _isContract(address account) private view returns (bool) {
    // This method relies on extcodesize, which returns 0 for contracts
    // in construction, since the code is only stored at the end of the
    // constructor execution.
    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }

  // Mints the token.
  function _mint(address to, uint256 tokenId) private {
    require(_minted <= _cap, "maximum amount of tokens minted");
    require(to != address(0), "tried to mint to the zero address");
    require(!_tokenExists(tokenId), "token already exists");
    _balances[to] += 1;
    _owners[tokenId] = to;
    _minted += 1;
    emit Transfer(address(0), to, tokenId);
  }

  // Safely mints token and transfers it.
  function _safeMint(address to, uint256 tokenId) private {
    _mint(to, tokenId);
    require(
      _checkOnZcopReceived(address(0), to, tokenId, ""),
      "does not implement ZcopReceiver"
    );
  }

  // Safely transfers a token by first checking that the contract
  // recipient implements the part of the ERC721 standard that prevents
  // tokens from being locked forever.
  function _safeTransfer(
    address from, address to, uint256 tokenId, bytes memory data
  ) 
    private 
  {
    _transfer(from, to, tokenId);
    require(
      _checkOnZcopReceived(from, to, tokenId, data),
      "client does not implementZcopReceiver"
    );
  }

  // Returns true if a token with the specified id exists. 
  function _tokenExists(uint256 tokenId) private view returns (bool) {
    // Accessing a map with an invalid key returns 0x0.
    return _owners[tokenId] != address(0);
  }

  // Transfers token.
  function _transfer(address from, address to, uint256 tokenId) private {
    require(ownerOf(tokenId) == from, "address does not own token");
    require(to != address(0), "tried to transfer to the zero address");
    _approve(address(0), tokenId);
    _balances[from] -= 1;
    _balances[to] += 1;
    _owners[tokenId] = to;
    emit Transfer(from, to, tokenId);
  }

  // Gives permission to transfer the token with the specified id to
  // another account.
  function approve(address to, uint256 tokenId) external {
    address owner = ownerOf(tokenId);
    require(to != owner, "approval to current owner");
    require(
      msg.sender == owner || isApprovedForAll(owner, msg.sender),
      "not owner nor approved for all"
    );
    _approve(to, tokenId);
  }

  // Returns the number of tokens in the specified owner's account.
  function balanceOf(address owner) external view returns (uint256) {
    require(owner != address(0), "queried balance for the zero address");
    return _balances[owner];
  }

  // Gets the approved address for the token.
  function getApproved(uint256 tokenId) public view returns (address) {
    require(_tokenExists(tokenId), "token does not exist");
    return _tokenApprovals[tokenId];
  }

  // Returns true if the operator is allowed to manage all of the 
  // token(s) of the owner.
  function isApprovedForAll(
    address owner, address operator
  ) 
    public view returns (bool) 
  {
    return _operatorApprovals[owner][operator];
  }

  // Returns the token collection name.
  function name() external pure returns (string memory) { return _name; }

  // Returns the owner of the token with the specified id.
  function ownerOf(uint256 tokenId) public view returns (address) {
    require(_tokenExists(tokenId), "token does not exist");
    return _owners[tokenId];
  }

  // Safely mints the token.
  function safeMint(address to, uint256 tokenId) external {
    require(_owner == msg.sender, "caller not owner");
    _safeMint(to, tokenId);
  }

  // Safely transfers a token.
  function safeTransferFrom(
    address from, address to, uint256 tokenId
  ) 
    external
  {
    safeTransferFrom(from, to, tokenId, "");
  }

  // Safely transfers a token.
  function safeTransferFrom(
    address from, address to, uint256 tokenId, bytes memory data
  )
    public
  {
    require(_isApprovedOrOwner(msg.sender, tokenId), "not owner nor approved");
    _safeTransfer(from, to, tokenId, data);
  }

  // Enables or disables approval for a third party to manage the token
  // for msg.sender.
  function setApprovalForAll(address operator, bool approved) external {
    require(operator != msg.sender, "tried to approve caller");
    _operatorApprovals[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  // Returns true if this contract implements the interface specified by
  // id as per Zcop.
  function supportsInterface(bytes4 id) external view returns (bool) {
    return _supportedInterfaces[id];
  }

  // Returns the token collection symbol.
  function symbol() external pure returns (string memory) { return _symbol; }

  // Returns the Uniform Resource Identifier (URI) for the token with
  // the specified id. 
  function tokenURI(uint256 tokenId) external view returns (string memory) {
    require(_tokenExists(tokenId), "token does not exist");
    return "ipfs://bafkreicoka7fblv4ahckakz2fzxfmh47s6zal3zklhce65girajfxs7djy";
  }

  // Returns the token's total supply.
  function totalSupply() external pure returns (uint256) { return _cap; }

  // Transfer the token with the specified id from one address to
  // another.
  function transferFrom(address from, address to, uint256 tokenId) external {
    require(_isApprovedOrOwner(msg.sender, tokenId), "not owner nor approved");
    _transfer(from, to, tokenId);
  }
}










