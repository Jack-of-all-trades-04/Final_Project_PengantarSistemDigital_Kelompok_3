library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.block_header.all;

entity blockchain_storage is
    Port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        write_en        : in  std_logic;
        
        write_idx       : in  std_logic_vector(7 downto 0); 
        write_data      : in  std_logic_vector(71 downto 0); 

        write_tx_amount : in  std_logic_vector(31 downto 0);
        write_tx_type   : in  std_logic_vector(1 downto 0);

        read_idx        : in  std_logic_vector(7 downto 0);
        read_data       : out std_logic_vector(71 downto 0);
        read_tx_amount  : out std_logic_vector(31 downto 0);
        read_tx_type    : out std_logic_vector(1 downto 0);

        head_idx_in     : in  std_logic_vector(7 downto 0);
        head_update     : in  std_logic;
        head_idx_out    : out std_logic_vector(7 downto 0);

        debug_block_mem      : out block_array_t;
        debug_tx_amount_mem  : out amount_array_t;
        debug_tx_type_mem    : out type_array_t
    );
end blockchain_storage;

architecture rtl of blockchain_storage is
    signal block_mem      : block_array_t := (others => (others => '0'));
    signal tx_amount_mem  : amount_array_t := (others => (others => '0'));
    signal tx_type_mem    : type_array_t   := (others => (others => '0'));
    signal head_idx : std_logic_vector(7 downto 0) := (others => '0');
begin
    read_data      <= block_mem(to_integer(unsigned(read_idx)));
    read_tx_amount <= tx_amount_mem(to_integer(unsigned(read_idx)));
    read_tx_type   <= tx_type_mem(to_integer(unsigned(read_idx)));
    
    debug_block_mem      <= block_mem;
    debug_tx_amount_mem  <= tx_amount_mem;
    debug_tx_type_mem    <= tx_type_mem;

    process(clk, reset)
    begin
        if reset = '1' then
            block_mem(0) <= x"00" & x"FF" & x"000000" & x"0000" & x"0000"; 
            tx_amount_mem(0) <= (others => '0');
            tx_type_mem(0)   <= "00";
            
            for i in 1 to 255 loop
                block_mem(i)     <= (others => '0');
                tx_amount_mem(i) <= (others => '0');
                tx_type_mem(i)   <= (others => '0');
            end loop;
            head_idx <= (others => '0');
        elsif rising_edge(clk) then
            if write_en = '1' then
                block_mem(to_integer(unsigned(write_idx)))     <= write_data;
                tx_amount_mem(to_integer(unsigned(write_idx))) <= write_tx_amount;
                tx_type_mem(to_integer(unsigned(write_idx)))   <= write_tx_type;
            end if;
            if head_update = '1' then
                head_idx <= head_idx_in;
            end if;
        end if;
    end process;
    head_idx_out <= head_idx;
end rtl;
