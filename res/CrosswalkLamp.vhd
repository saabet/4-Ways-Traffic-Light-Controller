library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity crosswalk_lamp is
  port (
    reset : in std_logic;
    clock : in std_logic;
    tombol : inout std_logic
  ) ;
end crosswalk_lamp ; 

architecture arch of crosswalk_lamp is
    --Component Low Lever Decoder BCD to 7-Segment
    component Decoder is
            port (
                clk : in std_logic;
                    bcd : in std_logic_vector(3 downto 0);  --BCD input
                    segment7 : out std_logic_vector(6 downto 0)  -- 7 bit decoded output.
                );
            end component;

    constant waktu_menyebrang : integer := 20; --limit waktu saat menyebrang = 20 detik
    constant waktu_tunggu : integer := 5; --limit waktu tunggu sesaat ada yang menekan tombol = 4 detik

    signal trigger_20 : std_logic := '0'; --trigger untuk memulai counter 20 detik
    signal trigger_5 : std_logic := '0'; --trigger untuk memulai counter 5 detik

    type state is (tidak_menyebrang, menyebrang, tunggu);   --Define State kondisi jalan raya
    signal PS, NS : state;

    type lampu is (merah, kuning, hijau);                   --Define warna yang akan menyala pada lampu
    signal lampu_jalanRaya, lampu_penyebrang : lampu;

    signal clock_count : integer := 0;                      --counter berdasarkan clock cycle
    signal inputPuluhan : std_logic_vector (3 downto 0);    --Input decoder untuk 7-segment puluhan
    signal inputSatuan : std_logic_vector (3 downto 0);     --Input decoder untuk 7 segement satuan
    signal outputPuluhan : std_logic_vector (6 downto 0);   --Output decoder untuk 7-segment puluhan
    signal outputSatuan : std_logic_vector (6 downto 0);    --Output decoder untuk 7-segemnt satuan

    

begin
        --define 2 decoder untuk 7-segment puluhan dan satuan
    decode_puluhan : Decoder port map (clock, inputPuluhan, outputPuluhan);
    decode_satuan : Decoder port map (clock, inputSatuan, outputSatuan);

    --Synchronous process (Merepresentasikan Flip FLop (terdapat Memory))
    sync_proc : process (reset, clock, NS) --Variable control ada reset clock, dan Next State (NS)
    begin
        if rising_edge(clock) then 
            PS <= NS;            
        elsif reset = '1' then
            PS <= tidak_menyebrang;    
        end if;
    end process sync_proc;

    --Combinatioral process 
    comb_proc : process (clock_count,tombol, PS) --Variable control ada clock-couter , tombol penyebrang (input 1 saat ada yang menekan tombol), Present State (PS)
    begin
        trigger_20 <= '0';
        trigger_5 <= '0';
        tombol <= '0';

        case PS is
            when tidak_menyebrang =>                --Kondisi saat tidak ada pejalan kaki yang ingin menyebrang
                lampu_jalanRaya <= hijau;           
                lampu_penyebrang <= merah;          
                if (tombol = '1') then              --Saat ada pejalan kaki yang menekan tombol ingin menyebrang jalan
                    NS <= tunggu;                   --Next state menjadi tunggu
                elsif (tombol = '0') then           --Jika tidak ada pejalan kaki yang menekan tombol
                    NS <= tidak_menyebrang;         --Next State tetap ke kondisi tidak_menyebrang
                end if;

            when tunggu =>                          --Kondisi sesaat setelah ada pejalan kaki yang menekan tombol
                lampu_jalanRaya <= kuning;          
                lampu_penyebrang <= kuning;         
                trigger_5 <= '1';                                       --Trigger counter 5 detik aktif
                if(clock_count = waktu_tunggu) then NS <= menyebrang;   --Setelah counter bernilai sama dengan waktu tunggu yaitu 5 maka NS menjadi kondisi menyebrang
                end if;

            when menyebrang =>                  --Kondisi saat pejalan kaki boleh menyebrang dan kendaraan wajib berhenti
                lampu_jalanRaya <= merah;
                lampu_penyebrang <= hijau;
                trigger_20 <= '1';                                                  --Trigger counter 20 detik aktif
                if (clock_count = waktu_menyebrang) then NS <= tidak_menyebrang;    --Setelah counter bernilai sama dengan waktu menyebrang yaitu 20 detik maka NS menjadi kondisi tidak menyebrang
                end if;
                tombol <= '0';                                                      --Reset tombol <= 0;
            end case;
            end process comb_proc;

        --Prosess counter waktu
        timer : process (trigger_20, trigger_5, clock)
        begin
            if trigger_5 = '1' then                                                 --Jika trigger counter 5 detik menyala, maka counter akan menghitung 5 kali clock cycle
                if rising_edge(clock) then                                          --Saat clock kondisi naik            
					clock_count <= clock_count + 1;                                 --Counter akan bertamabh 1
					if (clock_count = waktu_tunggu) then                            --Saat counter bernilai sama dengan waktu tunggu atau 5 detik
                        clock_count <= 0;                                           -- clock_count akan direset
					end if;
				end if;

            elsif trigger_20 = '1' then                                             --Jika trigger counter 20 detik menyala, maka counter akan menghitung 20 kali clock cycle
                if rising_edge(clock) then                                          -- saat clock kondisi naik
					clock_count <= clock_count + 1;                                 -- counter akan bertambah 1
					if (clock_count = waktu_menyebrang) then                        --Saat counter bernilai sama dengan waktu menyebrang atau 20
                        clock_count <= 0;                                           --Counter akan direset
					end if;
				end if;
            end if;
            end process timer;

        --proses input control untuk decoder puluhan dan satuan berdasarkan counter clock cycle        
        decCont : process (clock_count, trigger_5, trigger_20)
        begin
            --Saat kondisi tunggu atau sesaat setelah pejalan kaki menekan tombol
            --7 segment akan menampilkan hitung mundur 5 detik
            --Karena counter merupakan count up maka input decoder dibuat terbalik dengan counter
            if(trigger_5 = '1') then
                inputPuluhan <= "1111"; 
                case clock_count is
                    when 1 => inputSatuan <= "0101"; --5
                    when 2 => inputSatuan <= "0100"; --4
                    when 3 => inputSatuan <= "0011"; --3
                    when 4 => inputSatuan <= "0010"; --2
                    when 5 => inputSatuan <= "0001"; --1
                    when others => inputSatuan <= "1111"; --Mati
                end case;

            --Saat kondisi pejalan kaki menyebrang dan kendaraan wajib berhenti
            --7 segment akan menampilkan hitung mundur 20 detik
            --Karena counter merupakan count up, maka input decoder dibuat terbalik dengan counter
            elsif(trigger_20 = '1') then
                case clock_count is
                    when 1 =>                   
                        inputPuluhan <= "0010"; --20
                        inputSatuan <= "0000";
                    when 2 =>                   
                        inputPuluhan <= "0001"; --19
                        inputSatuan <= "1001";
                    when 3 => 
                        inputPuluhan <= "0001"; --18              
                        inputSatuan <= "1000";
                    when 4 =>  
                        inputPuluhan <= "0001"; --17           
                        inputSatuan <= "0111";
                    when 5 =>        
                        inputPuluhan <= "0001"; --16
                        inputSatuan <= "0110";
                    when 6 => 
                        inputPuluhan <= "0001"; --15
                        inputSatuan <= "0101";
                    when 7 =>   
                        inputPuluhan <= "0001"; --14
                        inputSatuan <= "0100";
                    when 8 =>
                        inputPuluhan <= "0001"; --13
                        inputSatuan <= "0011";
                    when 9 =>
                        inputPuluhan <= "0001"; --12
                        inputSatuan <= "0010";
                    when 10 =>
                        inputPuluhan <= "0001"; --11
                        inputSatuan <= "0001";
                    when 11 =>                   
                        inputPuluhan <= "0001"; --10
                        inputSatuan <= "0000";
                    when 12 =>                   
                        inputPuluhan <= "0000"; --9
                        inputSatuan <= "1001";
                    when 13 =>    
                        inputPuluhan <= "0000"; --8          
                        inputSatuan <= "1000";
                    when 14 => 
                        inputPuluhan <= "0000"; --7       
                        inputSatuan <= "0111";
                    when 15 => 
                        inputPuluhan <= "0000"; --6   
                        inputSatuan <= "0110";
                    when 16 => 
                        inputPuluhan <= "0000"; --5
                        inputSatuan <= "0101";
                    when 17 => 
                        inputPuluhan <= "0000"; --4
                        inputSatuan <= "0100";
                    when 18 =>
                        inputPuluhan <= "0000"; --3
                        inputSatuan <= "0011";
                    when 19 => 
                        inputPuluhan <= "0000"; --2
                        inputSatuan <= "0010";
                    when 20 =>
                        inputPuluhan <= "0000"; --1
                        inputSatuan <= "0001";
                    when others => 
                        inputPuluhan <= "1111"; --Mati
                        inputSatuan <= "1111"; --Mati
                end case;
            end if;
        end process ;


end architecture ;