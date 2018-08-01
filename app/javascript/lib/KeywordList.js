import Keyword from './Keyword'
import _ from 'lodash'

export default class KeywordList {
  constructor () {
    this.keywordList = []
  }
  add (keyword) {
    this.keywordList.push(keyword)
  }

  addEmpty () {
    const keyword = new Keyword({value: ''})
    this.add(keyword)
  }

  remove (keyword) {
    this.keywordList = this.keywordList.filter((key) => { return key !== keyword })
  }

  keywords () {
    return this.keywordList
  }

  load (attributes) {
    this.keywordList = []
    _.each(attributes, (keyword) => {
      const loadedKeyword = new Keyword({value: keyword})
      this.add(loadedKeyword)
    })
  }
}
