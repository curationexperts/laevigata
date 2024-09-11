export default class Member {
  constructor (options) {
    this.name = options.name
    this.affiliation = options.affiliation || ['Emory University']
    this.affiliationType = this.inferType(this.affiliation[0])
  }

  inferType (institution) {
    if (institution == 'Emory University' || !institution) {
      return 'Emory University'
    } else {
      return 'Non-Emory'
    }
  }
}
