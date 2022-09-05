import random as rd
from secrets import choice

MONEY_MIN = 0
MONEY_MAX = 1000
PKM_STAGE = {"Low": 1, "Mid": 2, "High": 4}
PKM_TYPE = {"Grass": 1, "Fire": 2, "Water": 4, "Electric": 8, "Normal": 5}

HP_INFO = {
    "Grass"   : {"Low": 128, "Mid": 192, "High": 254},
    "Fire"    : {"Low": 119, "Mid": 177, "High": 225},
    "Water"   : {"Low": 125, "Mid": 187, "High": 245},
    "Electric": {"Low": 122, "Mid": 182, "High": 235},
    "Normal"  : {"Low": 124}
}

ATK_INFO = {
    "Grass"   : {"Low": 63, "Mid": 94, "High": 123},
    "Fire"    : {"Low": 64, "Mid": 96, "High": 127},
    "Water"   : {"Low": 60, "Mid": 89, "High": 113},
    "Electric": {"Low": 65, "Mid": 97, "High": 124},
    "Normal"  : {"Low": 62}
}

EXP_INFO = {
    "Grass"   : {"Low": 32, "Mid": 63},
    "Fire"    : {"Low": 30, "Mid": 59},
    "Water"   : {"Low": 28, "Mid": 55},
    "Electric": {"Low": 26, "Mid": 51},
    "Normal"  : {"Low": 29}
}

fout = open("./dram.dat", "w")

def DRAM_data():
    # land data
    for addr in range(0x10000, 0x107fc, 8):
        # addr
        id = (addr-65536)/8
        print(int(id))
        
        fout.write('@' + format(addr, 'x') + '\n')
        if id%12 == 0:
            item_amount = 15
        else :
            item_amount = rd.randint(0,15)
        # Berry and Medicine
        # item_amount = rd.randint(0,15)
        fout.write('{:0>1x}'.format(item_amount, 'x'))
        # item_amount = rd.randint(0,15)
        fout.write('{:0>1x}'.format(item_amount, 'x') + ' ')
        #  Candy and Bracer
        # item_amount = rd.randint(0,15)
        fout.write('{:0>1x}'.format(item_amount, 'x'))

        # item_amount = rd.randint(0,15)
        fout.write('{:0>1x}'.format(item_amount, 'x') + ' ')

        if id%10:
            item_amount = 0
        else:
            item_amount = rd.randint(1,3)

        if id%12==1 :
            money = 0
        else:
            money = 500
        # rd.randint(MONEY_MIN, MONEY_MAX)

        # fout.write('stone: {:0>1x}'.format(item_amount, 'x') + ' ')
        # fout.write('money: {:0>4x}'.format(money, 'x') + ' ')
        to_dram = item_amount*(2**14)+money
        # fout.write('{:0>4x}'.format(to_dram, 'x') + ' ')
        fout.write('{:0>2x}'.format(int(to_dram/(2**8)), 'x') + ' ')
        fout.write('{:0>1x}'.format(int(to_dram%(2**8)), 'x') + '\n')

        fout.write('@' + format(addr + 4, 'x') + '\n')

        # have_pkm = rd.choices([1,0],[0.8,0.2])
        if id%8==0 :
            have_pkm = '0'
        else:
            have_pkm = '1'
        # print(have_pkm)
        if have_pkm[0] == '1':
            # pkm_type = rd.choice(["Grass", "Fire", "Water", "Electric", "Normal"])
            
            if id%6==1 :
                pkm_type = "Grass"
            elif id%6==2:
                pkm_type = "Fire"
            elif id%6==3:
                pkm_type = "Water"
            elif id%6==4:
                pkm_type = "Electric"
            else:
                pkm_type = "Normal"

            if pkm_type=="Normal":
                pkm_stage = "Low"
            else :
                pkm_stage = rd.choice(["Low", "Mid", "High"])
            # stage
            fout.write('{:0>1x}'.format(PKM_STAGE[pkm_stage], 'x'))
            
            # type
            fout.write('{:0>1x}'.format(PKM_TYPE[pkm_type], 'x') + ' ')
            
            # hp info
            if id%10==0 :
                cur_hp = 0
            else:
                cur_hp = rd.randint(0, HP_INFO[pkm_type][pkm_stage])
            
            fout.write('{:0>2x}'.format(cur_hp, 'x') + ' ')
            
            # attck info
            fout.write('{:0>2x}'.format(ATK_INFO[pkm_type][pkm_stage], 'x') + ' ')
            
            # exp info
            if pkm_stage == "High":
                cur_exp = 0
            else :
                cur_exp = rd.randint((EXP_INFO[pkm_type][pkm_stage]-10), (EXP_INFO[pkm_type][pkm_stage]-1))

            fout.write('{:0>2x}'.format(cur_exp, 'x') + '\n')
   
        else :
            fout.write('{:0>2x}'.format(0, 'x') + ' ' + '{:0>2x}'.format(0, 'x') + ' ' + '{:0>2x}'.format(0, 'x') + ' ' + '{:0>2x}'.format(0, 'x') + '\n')
       
        
DRAM_data()