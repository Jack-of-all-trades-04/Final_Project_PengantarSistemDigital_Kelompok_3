library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.block_header.all; 

entity miner is
    port(
        clk             : in  std_logic;
        reset           : in  std_logic;
        prev_header_in  : in  std_logic_vector(66 downto 0);
	current_idx_in  : in  std_logic_vector(2 downto 0);

        miner_id_in     : in  std_logic_vector(7 downto 0);
        target_bits     : in  std_logic_vector(63 downto 0);

        block_found     : out std_logic;
        mined_block_out : out std_logic_vector(66 downto 0)
    );
end entity;

architecture Behavioral of miner is

    signal nonce       : unsigned(31 downto 0) := (others => '0');
    signal lfsr        : std_logic_vector(15 downto 0) := (others => '1');

    signal hash_val    : std_logic_vector(63 downto 0);
    signal found_reg   : std_logic := '0';
    signal timestamp   : unsigned(23 downto 0) := (others => '0');

    signal header_struct : block_header_t;
    signal header_packed : std_logic_vector(66 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                lfsr <= miner_id_in & "10101010";
            else
                lfsr <= lfsr(14 downto 0) & (lfsr(15) xor lfsr(13));
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                nonce <= (others => '0');
            else
                nonce <= nonce + 1 + to_integer(unsigned(miner_id_in(1 downto 0)));
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                timestamp <= (others => '0');
            else
                timestamp <= timestamp + 1;
            end if;
        end if;
    end process;

    hash_val <= std_logic_vector(
                    rotate_left(
                        unsigned(prev_header_in(63 downto 0))
                        xor resize(unsigned(std_logic_vector'(lfsr & lfsr)), 64) 
                        xor resize(nonce, 64),
                        7
                    )
                );

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                found_reg <= '0';
                header_struct.prev_index    <= (others => '0');
                header_struct.miner_id      <= (others => '0');
                header_struct.timestamp     <= (others => '0');
                header_struct.nonce         <= (others => '0');
                header_struct.hash_fragment <= (others => '0');
                header_packed <= (others => '0');
            else
                if unsigned(hash_val) < unsigned(target_bits) then
                    found_reg <= '1';

                    header_struct.prev_index    <= current_idx_in;
                    header_struct.miner_id      <= miner_id_in;
                    header_struct.timestamp     <= std_logic_vector(timestamp);
                    header_struct.nonce         <= std_logic_vector(nonce(15 downto 0));
                    header_struct.hash_fragment <= hash_val(15 downto 0);

                    header_packed <= pack_header(header_struct);

                else
                    found_reg <= '0';
                    -- header_packed <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    block_found     <= found_reg;
    mined_block_out <= header_packed when found_reg = '1' else (others => '0');

end architecture;

