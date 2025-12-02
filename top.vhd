library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity top is
    port(
        clk    : in  std_logic;
        reset  : in  std_logic;

        dbg_head_idx_out   : out std_logic_vector(2 downto 0);
        dbg_write_en       : out std_logic;
        dbg_write_idx      : out std_logic_vector(2 downto 0);
        dbg_write_data     : out std_logic_vector(66 downto 0);

        dbg_minerA_found   : out std_logic;
        dbg_minerB_found   : out std_logic_vector(0 downto 0);
        dbg_minerA_block   : out std_logic_vector(66 downto 0);
        dbg_minerB_block   : out std_logic_vector(66 downto 0);
        dbg_winner_id      : out std_logic_vector(7 downto 0);

        dbg_wallet_deposit_req : out std_logic;
        dbg_wallet_amount_out  : out std_logic_vector(31 downto 0);
        dbg_walletA_balance    : out std_logic_vector(31 downto 0);
        dbg_walletB_balance    : out std_logic_vector(31 downto 0)
    );
end entity;

architecture Structural of top is

    signal head_idx_out      : std_logic_vector(2 downto 0);
    signal current_head_idx  : std_logic_vector(2 downto 0);
    signal read_data_dummy   : std_logic_vector(66 downto 0);

    signal minerA_prev_header : std_logic_vector(66 downto 0);
    signal minerA_found_sig   : std_logic;
    signal minerA_block_out   : std_logic_vector(66 downto 0);
    signal minerA_id          : std_logic_vector(7 downto 0) := x"0A";
    signal target_bits 	      : std_logic_vector(63 downto 0) := (others => '1');

    signal minerB_prev_header : std_logic_vector(66 downto 0);
    signal minerB_found_sig   : std_logic;
    signal minerB_block_out   : std_logic_vector(66 downto 0);
    signal minerB_id          : std_logic_vector(7 downto 0) := x"0B"; 

    signal write_en_sig       : std_logic;
    signal write_idx_sig      : std_logic_vector(2 downto 0);
    signal write_data_sig     : std_logic_vector(66 downto 0);
    signal head_update        : std_logic;
    signal new_head_idx       : std_logic_vector(2 downto 0);
    signal winner_id_sig      : std_logic_vector(7 downto 0);

    signal wallet_deposit_req_sig : std_logic;
    signal wallet_amount_out_sig  : std_logic_vector(31 downto 0);
    signal wallet_load_req_sig    : std_logic;
    signal wallet_id_out_sig      : std_logic_vector(15 downto 0);

    signal walletA_balance_sig : std_logic_vector(31 downto 0);
    signal walletB_balance_sig : std_logic_vector(31 downto 0);

begin
    bc_storage_inst : entity work.blockchain_storage
        port map(
            clk           => clk,
            reset         => reset,
            write_en      => write_en_sig,
            write_idx     => write_idx_sig,
            write_data    => write_data_sig,
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
            block_found    => minerA_found_sig,
            mined_block_out => minerA_block_out
        );

    minerB_inst : entity work.miner
        port map(
            clk            => clk,
            reset          => reset,
            prev_header_in => minerB_prev_header,
            miner_id_in    => minerB_id,
            target_bits    => target_bits,
            block_found    => minerB_found_sig,
            mined_block_out => minerB_block_out
        );

    consensus_inst : entity work.consensus_controller
        port map(
            clk               => clk,
            reset             => reset,
            minerA_found      => minerA_found_sig,
            minerA_block      => minerA_block_out,
            minerA_id         => minerA_id,
            minerB_found      => minerB_found_sig,
            minerB_block      => minerB_block_out,
            minerB_id         => minerB_id,
            current_head_idx  => current_head_idx,
            write_en          => write_en_sig,
            write_idx         => write_idx_sig,
            write_data        => write_data_sig,
            head_update       => head_update,
            new_head_idx      => new_head_idx,
            winner_id         => winner_id_sig,

            wallet_deposit_req => wallet_deposit_req_sig,
            wallet_amount_out  => wallet_amount_out_sig,
            wallet_load_req    => wallet_load_req_sig,
            wallet_id_out      => wallet_id_out_sig
        );

    wallet_inst : entity work.wallet_dual
        port map(
            clk                 => clk,
            reset               => reset,
            wallet_load_req     => wallet_load_req_sig,
            wallet_id_in        => wallet_id_out_sig,
            deposit_req         => wallet_deposit_req_sig,
            amount_in           => wallet_amount_out_sig,

            walletA_balance_out => walletA_balance_sig,
            walletB_balance_out => walletB_balance_sig
        );

    dbg_head_idx_out   <= head_idx_out;
    dbg_write_en       <= write_en_sig;
    dbg_write_idx      <= write_idx_sig;
    dbg_write_data     <= write_data_sig;

    dbg_minerA_found   <= minerA_found_sig;
    dbg_minerA_block   <= minerA_block_out;
    dbg_minerB_found(0) <= minerB_found_sig;
    dbg_minerB_block   <= minerB_block_out;
    dbg_winner_id      <= winner_id_sig;

    dbg_wallet_deposit_req <= wallet_deposit_req_sig;
    dbg_wallet_amount_out  <= wallet_amount_out_sig;

    dbg_walletA_balance <= walletA_balance_sig;
    dbg_walletB_balance <= walletB_balance_sig;

end architecture;

