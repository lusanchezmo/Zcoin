
// Agregar el programa de solidity
pragma solidity >=0.7.0 <0.9.0;

//Creacion del programa nombre y simbolo del mismo
contract cupicoin {

    string public name;
    string public symbol;
    uint8 public decimals;    //  número de decimales que usa el token; por ejemplo 8, significa dividir la cantidad del token 100000000para obtener su representación de usuario.
    uint256 public totalSupply;   // Devuelve el suministro total de token
    mapping(address => u int256) public balaceOf;   //Devuelve el saldo de cuenta de otra cuenta con dirección 

    //Trasferencias hacia otros usuarios
    function transfer(address _to, uint256 _value) public returns (bool success)
        require (balance()f[msg.sender] >= _value)

    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}