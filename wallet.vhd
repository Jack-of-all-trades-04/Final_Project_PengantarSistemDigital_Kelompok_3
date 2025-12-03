library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wallet is
    generic (
        WALLET_ID_WIDTH : integer := 16;
        BALANCE_WIDTH   : integer := 32
    );
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;

        wallet_id_in    : in  std_logic_vector(WALLET_ID_WIDTH-1 downto 0);
        wallet_load_req : in  std_logic;
        deposit_req     : in  std_logic;
        amount_in       : in  std_logic_vector(BALANCE_WIDTH-1 downto 0);

        tx_req          : in  std_logic;                      
        tx_from         : in  std_logic;                      -- '0' => A->B, '1' => B->A
        tx_amount_in    : in  std_logic_vector(BALANCE_WIDTH-1 downto 0);
        tx_success_out  : out std_logic;                      

        walletA_balance_out : out std_logic_vector(BALANCE_WIDTH-1 downto 0);
        walletB_balance_out : out std_logic_vector(BALANCE_WIDTH-1 downto 0);
        last_wallet_id_out  : out std_logic_vector(WALLET_ID_WIDTH-1 downto 0);
        valid_op_out        : out std_logic
    );
end entity;

architecture Behavioral of wallet is
    constant ID_A : unsigned(WALLET_ID_WIDTH-1 downto 0) :=
        to_unsigned(16#000A#, WALLET_ID_WIDTH);

    constant ID_B : unsigned(WALLET_ID_WIDTH-1 downto 0) :=
        to_unsigned(16#000B#, WALLET_ID_WIDTH);

    signal balance_A : unsigned(BALANCE_WIDTH-1 downto 0) := (others => '0');
    signal balance_B : unsigned(BALANCE_WIDTH-1 downto 0) := (others => '0');

    signal last_id_reg : std_logic_vector(WALLET_ID_WIDTH-1 downto 0) := (others => '0');
    signal valid_reg    : std_logic := '0';

begin
    process(clk, reset)
        variable amount_val : unsigned(BALANCE_WIDTH-1 downto 0);
        variable wid        : unsigned(WALLET_ID_WIDTH-1 downto 0);
        variable tx_amount  : unsigned(BALANCE_WIDTH-1 downto 0);
    begin
        if reset = '1' then
            balance_A    <= (others => '0');
            balance_B    <= (others => '0');
            last_id_reg  <= (others => '0');
            valid_reg    <= '0';
            tx_success_out <= '0';

        elsif rising_edge(clk) then
            valid_reg <= '0';
            tx_success_out <= '0';

            amount_val := unsigned(amount_in);
            wid        := unsigned(wallet_id_in);
            tx_amount  := unsigned(tx_amount_in);

            if wallet_load_req = '1' then
                last_id_reg <= wallet_id_in;
                valid_reg   <= '1';
            end if;

            if deposit_req = '1' then
                if wid = ID_A then
                    balance_A <= balance_A + amount_val;
                    valid_reg <= '1';
                elsif wid = ID_B then
                    balance_B <= balance_B + amount_val;
                    valid_reg <= '1';
                else
                    valid_reg <= '0';
                end if;
                last_id_reg <= wallet_id_in;
            end if;

            if tx_req = '1' then
                if tx_from = '0' then
                    -- A -> B
                    if balance_A >= tx_amount then
                        balance_A <= balance_A - tx_amount;
                        balance_B <= balance_B + tx_amount;
                        tx_success_out <= '1';
                        valid_reg <= '1';
                    else
                        tx_success_out <= '0';
                        valid_reg <= '0';
                    end if;
                else
                    -- B -> A
                    if balance_B >= tx_amount then
                        balance_B <= balance_B - tx_amount;
                        balance_A <= balance_A + tx_amount;
                        tx_success_out <= '1';
                        valid_reg <= '1';
                    else
                        tx_success_out <= '0';
                        valid_reg <= '0';
                    end if;
                end if;
                last_id_reg <= wallet_id_in; 
            end if;

        end if;
    end process;

    walletA_balance_out <= std_logic_vector(balance_A);
    walletB_balance_out <= std_logic_vector(balance_B);
    last_wallet_id_out  <= last_id_reg;
    valid_op_out        <= valid_reg;

end architecture;

