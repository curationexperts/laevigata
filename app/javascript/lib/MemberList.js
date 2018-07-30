import Member from './Member'
import _ from 'lodash'

export default class MemberList {
  constructor () {
    this.memberList = []
  }
  add (member) {
    this.memberList.push(member)
  }

  addEmpty () {
    const member = new Member({ name: '', affiliation: 'Emory University', affiliationType: 'Emory University' })
    this.add(member)
  }

  remove (member) {
    this.memberList = this.memberList.filter((committeeMember) => { return committeeMember !== member })
  }

  members () {
    return this.memberList
  }

  load (attributes) {
    this.memberList = []
    _.each(attributes, (member) => {
      const loadedMember = new Member({name: member.name, affiliation: member.affiliation, affiliationType: member['affiliation_type']})
      this.add(loadedMember)
    })
  }
}
