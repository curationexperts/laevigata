import Chair from './Chair'
import _ from 'lodash'

export default class ChairList {
  constructor () {
    this.chairList = []
  }
  add (chair) {
    this.chairList.push(chair)
  }

  addEmpty () {
    const chair = new Chair({ name: '', affiliation: 'Emory University', affiliationType: 'Emory University' })
    this.add(chair)
  }

  remove (chair) {
    this.chairList = this.chairList.filter((committeeChair) => { return committeeChair !== chair })
  }

  chairs () {
    return this.chairList
  }

  load (attributes) {
    this.chairList = []
    _.each(attributes, (chair) => {
      const loadedChair = new Chair({name: chair.name, affiliation: chair.affiliation, affiliationType: chair['affiliation_type']})
      this.add(loadedChair)
    })
  }
}
