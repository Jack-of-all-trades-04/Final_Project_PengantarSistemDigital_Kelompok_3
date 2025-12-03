library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

package block_header is
    type block_header_t is record
        prev_index     : std_logic_vector(7 downto 0);
        miner_id       : std_logic_vector(7 downto 0);
        timestamp      : std_logic_vector(23 downto 0);
        nonce          : std_logic_vector(15 downto 0);
        hash_fragment  : std_logic_vector(15 downto 0);
    end record;

    type block_array_t is array (0 to 255) of std_logic_vector(71 downto 0);
    type amount_array_t is array (0 to 255) of std_logic_vector(31 downto 0);
    type type_array_t   is array (0 to 255) of std_logic_vector(1 downto 0);

    function pack_header(h : block_header_t) return std_logic_vector;
    function unpack_header(vec : std_logic_vector(71 downto 0)) return block_header_t;
    function make_hash_input(h : block_header_t) return std_logic_vector;

end package block_header;

package body block_header is
    function pack_header(h : block_header_t) return std_logic_vector is
        variable output : std_logic_vector(71 downto 0); -- UPGRADE
    begin
        output:= h.prev_index & h.miner_id & h.timestamp & h.nonce & h.hash_fragment;
        return output;
    end function;

    function unpack_header(vec : std_logic_vector(71 downto 0)) return block_header_t is
        variable h : block_header_t;
    begin
        h.prev_index     := vec(71 downto 64);
        h.miner_id       := vec(63 downto 56);
        h.timestamp      := vec(55 downto 32);
        h.nonce          := vec(31 downto 16);
        h.hash_fragment  := vec(15 downto 0);
        return h;
    end function;

    function make_hash_input(h : block_header_t) return std_logic_vector is
        variable tmp : std_logic_vector(63 downto 0);
    begin
        tmp := (others => '0');
        tmp(50 downto 48) := h.prev_index(2 downto 0); 
        tmp(47 downto 40) := h.miner_id;
        tmp(39 downto 16) := h.timestamp;
        tmp(15 downto 0)  := h.nonce;
        return tmp;
    end function;
end package body;
