library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity blockchain_storage is
    Port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        write_en  : in  std_logic;
        write_idx : in  std_logic_vector(2 downto 0);
        write_data: in  std_logic_vector(66 downto 0);
        read_idx  : in  std_logic_vector(2 downto 0);
        read_data : out std_logic_vector(66 downto 0);
        head_idx_in  : in  std_logic_vector(2 downto 0);
        head_update  : in  std_logic;  -- update head pointer
        head_idx_out : out std_logic_vector(2 downto 0)
    );
end blockchain_storage;


architecture rtl of blockchain_storage is
    type block_array_t is array (0 to 7) of std_logic_vector(66 downto 0);
    signal block_mem : block_array_t := (others => (others => '0'));
    signal head_idx : std_logic_vector(2 downto 0) := "000";

begin
    read_data <= block_mem(to_integer(unsigned(read_idx)));
    process(clk, reset)
    begin
        if reset = '1' then
            block_mem <= (others => (others => '0'));
            head_idx  <= "000";

        elsif rising_edge(clk) then
            if write_en = '1' then
                block_mem(to_integer(unsigned(write_idx))) <= write_data;
            end if;
            if head_update = '1' then
                head_idx <= head_idx_in;
            end if;

        end if;
    end process;

    head_idx_out <= head_idx;

end rtl;
