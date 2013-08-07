require! '../lib/zhutil'

expectZH = (input, expected) ->
  actual = zhutil.parseZHNumber(input)
  if actual != expected
    console.log input + ': FAIL'
    console.log "  EXPECTED: " + expected
    console.log "  ACTUAL: " + actual
  else
    console.log input + ': PASS'

expectZH '零', 0
expectZH '一', 1
expectZH '十', 10
expectZH '十二', 12
expectZH '二十', 20
expectZH '三十四', 34
expectZH '五百', 500
expectZH '六百七十', 670
expectZH '六百零九', 609
expectZH '陸佰捌拾玖', 689
expectZH '七千', 7000
expectZH '七千零八十六', 7086
expectZH '七千零二十', 7020
expectZH '七千三百零二', 7302
expectZH '一萬兩千三百四十五', 12345
expectZH '壹萬貳仟參佰肆拾伍', 12345
expectZH '一萬零一', 10001
expectZH '一萬零三百零一', 10301
expectZH '三百０五萬０七百０九', 3050709
expectZH '玖億零捌', 900000008
expectZH '玖億捌仟柒佰陸拾伍萬', 987650000
expectZH '玖億捌仟柒佰陸拾伍萬肆仟參佰貳拾壹', 987654321
expectZH '一兆五千零三十', 1000000005030
expectZH '一兆一千萬零十一', 1000010000011

# non-natural cases
expectZH '一百十二', 112
