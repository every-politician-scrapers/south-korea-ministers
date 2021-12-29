module.exports = (id, startdate, enddate) => {
  qualifier = { }
  if(startdate) qualifier['P580'] = startdate
  if(enddate)   qualifier['P582'] = enddate

  return {
    id,
    claims: {
      P39: {
        value: 'Q16178356',
        qualifiers: qualifier,
        references: { P4656: 'https://ko.wikipedia.org/wiki/%EB%8C%80%ED%95%9C%EB%AF%BC%EA%B5%AD%EC%9D%98_%EA%B8%88%EC%9C%B5%EC%9C%84%EC%9B%90%ED%9A%8C_%EC%9C%84%EC%9B%90%EC%9E%A5' }
      }
    }
  }
}
