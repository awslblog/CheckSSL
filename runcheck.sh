curl https://${1} -v -s -o /dev/null 2> ./tmp/ca.info

cat ./tmp/ca.info | grep 'start date: ' > ./tmp/${1}.info
cat ./tmp/ca.info | grep 'expire date: ' >> ./tmp/${1}.info
cat ./tmp/ca.info | grep 'issuer: ' >> ./tmp/${1}.info
cat ./tmp/ca.info | grep 'SSL certificate verify' >> ./tmp/${1}.info

sed -i 's|\* start date: ||g' ./tmp/api/ct.json
sed -i 's|\* expire date: ||g' ./tmp/api/ct.json
sed -i 's|\* issuer: ||g' ./tmp/api/ct.json
sed -i 's|\* SSL certificate verify ||g' ./tmp/api/ct.json
sed -i 's|ok.|ok|g' ./tmp/api/ct.json

start=$(sed -n '1p' ./tmp/${1}.info)
expire=$(sed -n '2p' ./tmp/${1}.info)
issuer=$(sed -n '3p' ./tmp/${1}.info)
status=$(sed -n '4p' ./tmp/${1}.info)

rm -f tmp/ca.info
rm -f tmp/${1}.info

mkdir tmp -p

DATE="$(echo $(date '+%Y-%m-%d %H:%M:%S'))"

nowstamp="$(date -d "$DATE" +%s)"
expirestamp="$(date -d "$expire" +%s)"
expireday=`expr $[expirestamp-nowstamp] / 86400`

echo '{' > tmp/${1}.json
echo '"domain": "'${1}'",' >> ./tmp/${1}.json
echo '"start": "'$start'",' >> ./tmp/${1}.json
echo '"expire": "'$expire'",' >> ./tmp/${1}.json
echo '"issuer": "'$issuer'",' >> ./tmp/${1}.json
echo '"status": "'$status'",' >> ./tmp/${1}.json
echo '"check": "'$DATE'"' >> ./tmp/${1}.json
echo '"remain": "'$expireday'"' >> ./tmp/${1}.json
echo '},' >> ./tmp/${1}.json
