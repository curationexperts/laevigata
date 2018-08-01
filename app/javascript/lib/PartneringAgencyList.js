import PartneringAgency from './PartneringAgency'
import _ from 'lodash'
import axios from 'axios'
import { formStore } from '../formStore'

export default class PartneringAgencyList {
  constructor () {
    this.partneringAgencyList = []
  }
  add (partneringAgency) {
    this.partneringAgencyList.push(partneringAgency)
  }

  addEmpty () {
    const partneringAgency = new PartneringAgency({value: ''})
    this.add(partneringAgency)
  }

  remove (partneringAgency) {
    this.partneringAgencyList = this.partneringAgencyList.filter((agency) => { return agency !== partneringAgency })
  }

  partneringAgencies () {
    return this.partneringAgencyList
  }

  load (attributes) {
    this.partneringAgencyList = []
    _.each(attributes, (partneringAgency) => {
      const loadedPartneringAgency = new PartneringAgency({value: partneringAgency})
      this.add(loadedPartneringAgency)
    })
  }
}
