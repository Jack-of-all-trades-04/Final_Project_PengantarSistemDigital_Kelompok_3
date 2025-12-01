library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity top is
    port(
        clk    : in  std_logic;
        reset  : in  std_logic
    );
end entity;

architecture Structural of top is
    signal head_idx_out      : std_logic_vector(2 downto 0);
    signal current_head_idx  : std_logic_vector(2 downto 0);
    signal read_data_dummy   : std_logic_vector(66 downto 0);

    signal minerA_prev_header : std_logic_vector(66 downto 0);
    signal minerA_found       : std_logic;
    signal minerA_block_out   : std_logic_vector(66 downto 0);
    signal minerA_id          : std_logic_vector(7 downto 0) := x"0A";
    signal target_bits        : std_logic_vector(63 downto 0) := (others => '0');

    signal minerB_prev_header : std_logic_vector(66 downto 0);
    signal minerB_found       : std_logic;
    signal minerB_block_out   : std_logic_vector(66 downto 0);
    signal minerB_id          : std_logic_vector(7 downto 0) := x"0B"; 

    signal write_en        : std_logic;
    signal write_idx       : std_logic_vector(2 downto 0);
    signal write_data      : std_logic_vector(66 downto 0);
    signal head_update     : std_logic;
    signal new_head_idx    : std_logic_vector(2 downto 0);
    signal winner_id       : std_logic_vector(7 downto 0);

    signal wallet_deposit_req : std_logic;
    signal wallet_amount_out  : std_logic_vector(31 downto 0);
    signal wallet_load_req    : std_logic;
    signal wallet_id_out      : std_logic_vector(15 downto 0);

    signal wallet_balance_out : std_logic_vector(31 downto 0);
    signal wallet_valid       : std_logic;

begin
    bc_storage_inst : entity work.blockchain_storage
        port map(
            clk           => clk,
            reset         => reset,
            write_en      => write_en,
            write_idx     => write_idx,
            write_data    => write_data,
            read_idx      => head_idx_out,
            read_data     => read_data_dummy,
            head_idx_in   => new_head_idx,
            head_update   => head_update,
            head_idx_out  => head_idx_out
        );

    current_head_idx <= head_idx_out;

    minerA_prev_header <= read_data_dummy;
    minerB_prev_header <= read_data_dummy;

    minerA_inst : entity work.miner
        port map(
            clk            => clk,
            reset          => reset,
            prev_header_in => minerA_prev_header,
            miner_id_in    => minerA_id,
            target_bits    => target_bits,
            block_found    => minerA_found,
            mined_block_out => minerA_block_out
        );

    minerB_inst : entity work.miner
        port map(
            clk            => clk,
            reset          => reset,
            prev_header_in => minerB_prev_header,
            miner_id_in    => minerB_id,
            target_bits    => target_bits,
            block_found    => minerB_found,
            mined_block_out => minerB_block_out
        );

    consensus_inst : entity work.consensus_controller
        port map(
            clk               => clk,
            reset             => reset,
            minerA_found      => minerA_found,
            minerA_block      => minerA_block_out,
            minerA_id         => minerA_id,
            minerB_found      => minerB_found,
            minerB_block      => minerB_block_out,
            minerB_id         => minerB_id,
            current_head_idx  => current_head_idx,
            write_en          => write_en,
            write_idx         => write_idx,
            write_data        => write_data,
            head_update       => head_update,
            new_head_idx      => new_head_idx,
            winner_id         => winner_id,

            wallet_deposit_req => wallet_deposit_req,
            wallet_amount_out  => wallet_amount_out,
            wallet_load_req    => wallet_load_req,
            wallet_id_out      => wallet_id_out
        );

    wallet_inst : entity work.wallet
        port map(
            clk           => clk,
            reset         => reset,
            wallet_id_in  => wallet_id_out,
            wallet_load   => wallet_load_req,
            deposit_req   => wallet_deposit_req,
            withdraw_req  => '0',                     
            amount_in     => wallet_amount_out,
            wallet_id_out => open,                     
            balance_out   => wallet_balance_out,
            valid_op_out  => wallet_valid
        );

end architecture;

