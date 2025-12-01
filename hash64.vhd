library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity hash64 is
    Port (
        data_input  : in  std_logic_vector(63 downto 0);
        hash_out : out std_logic_vector(63 downto 0)
    );
end hash64;

architecture rtl of hash64 is

    constant CONST1 : unsigned(63 downto 0) := x"9E3779B97F4A7C15";
    constant CONST2 : unsigned(63 downto 0) := x"C2B2AE3D27D4EB4F";
    constant CONST3 : unsigned(63 downto 0) := x"165667B19E3779F9";
    constant CONST4 : unsigned(63 downto 0) := x"D6E8FEB86659FD93";

    function rotasi_kiri(val : unsigned; sh : integer) return unsigned is
    begin
        return (val rol sh);
    end function;

    function rotasi_kanan(val : unsigned; sh : integer) return unsigned is
    begin
        return (val ror sh);
    end function;

begin

    process(data_input)
        variable state : unsigned(63 downto 0);
        variable din   : unsigned(63 downto 0);
    begin
        din   := unsigned(data_input);
        state := din;

        state := rotasi_kiri(state, 7) xor CONST1;
        state := state + CONST2;

        state := rotasi_kanan(state, 3) xor rotasi_kanan(din, 11);
        state := state + CONST3;

        state := rotasi_kiri(state, 17) xor (din srl 5);
        state := state + CONST4;

        state := rotasi_kanan(state, 10) xor rotasi_kanan(din, 11);
        state := state + CONST1;

        hash_out <= std_logic_vector(state);
    end process;

end rtl;

