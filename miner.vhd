library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.block_header.all;

entity miner is
    port(
        clk             : in  std_logic;
        reset           : in  std_logic;
        prev_header_in  : in  std_logic_vector(71 downto 0);
        current_idx_in  : in  std_logic_vector(7 downto 0);
        miner_id_in     : in  std_logic_vector(7 downto 0);
        target_bits     : in  std_logic_vector(63 downto 0);

        block_found     : out std_logic;
        mined_block_out : out std_logic_vector(71 downto 0)
    );
end entity;

architecture Behavioral of miner is

    signal nonce       : unsigned(31 downto 0) := (others => '0');
    signal timestamp   : unsigned(23 downto 0) := (others => '0');
    
    signal hash_input_vec : std_logic_vector(63 downto 0);
    signal hash_output_vec: std_logic_vector(63 downto 0);
    
    signal candidate_header : block_header_t;
    signal header_packed    : std_logic_vector(71 downto 0);
    signal found_reg        : std_logic := '0';

begin

    hasher_inst : entity work.hash64
        port map(
            data_input => hash_input_vec,
            hash_out   => hash_output_vec
        );

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

    process(current_idx_in, miner_id_in, timestamp, nonce, hash_output_vec)
    begin
        candidate_header.prev_index    <= current_idx_in;
        candidate_header.miner_id      <= miner_id_in;
        candidate_header.timestamp     <= std_logic_vector(timestamp);
        candidate_header.nonce         <= std_logic_vector(nonce(15 downto 0));
        candidate_header.hash_fragment <= hash_output_vec(15 downto 0);
    end process;

    hash_input_vec <= make_hash_input(candidate_header);

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                found_reg <= '0';
                header_packed <= (others => '0');
            else
                if unsigned(hash_output_vec) <= unsigned(target_bits) then
                    found_reg <= '1';
                    header_packed <= pack_header(candidate_header);
                else
                    found_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    block_found     <= found_reg;
    mined_block_out <= header_packed when found_reg = '1' else (others => '0');

end architecture;
