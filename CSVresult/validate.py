def isRefCorrect(referencenumber):
    
    listed = list(referencenumber)

    checknumber = listed.pop()
    totalAmount = 0
    product = 1

    while (len(listed) > 0):
        if ( product == 1):
            product = 7
            totalAmount = totalAmount + (product * int(listed.pop()))
        elif (product == 3):
            product = 1
            totalAmount = totalAmount + (product * int(listed.pop()))
        else:
            product = 3
            totalAmount = totalAmount + (product * int(listed.pop()))

    #print ("Total: " + str(totalAmount))

    result = (10 - (totalAmount % 10)) % 10

    if (result == int(checknumber)):
        return True
    return False

def isEqual(headerTotal, rowTotal, maxDifference):

    if ( abs(headerTotal-rowTotal) < maxDifference ):
        return True
    return False

if __name__ == '__main__':
    ref = '217356'  #7672682
    val = isRefCorrect(ref)
    print(val)