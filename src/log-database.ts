import { Client } from "pg"
import "dotenv/config"
import log from "./log"

export class LogDatabase {
  client:Client
  constructor ()  {
      console.log(process.env.DATABASE_USER)
      this.client = new Client({
        user: process.env.DATABASE_USER,
        host: process.env.DATABASE_HOST,
        database: "nsevents",
        password: process.env.DATABASE_PASSWORD,
        port: process.env.DATABASE_PORT as unknown as number,
      })
  }
  initDatabase = async () => {
    let client = await this.client.connect()
    await this.buildFromSchema()
    return client
  }
  logToDatabase = async function (
    mrId: number,
    formattedData: string | object,
    message: string
  ) {
    console.log("TRYINGGGG")
    await this.client.query(`INSERT INTO ns_logs (created_at, mr_id, raw_data,  message)
      VALUES (NOW(), ${mrId},  '${formattedData}', '${message}');`)
  }
  getLogs = async function(mrId: number, c:Client = module.exports.client) { 
    return await this.client.query(`SELECT * FROM ns_logs WHERE mr_id = ${mrId}`).catch((e: any)=>log.error(`SQL READ ERROR: ${e}`))
  }
  buildFromSchema = async function () {
    await this.client.query(`
              CREATE TABLE IF NOT EXISTS ns_logs (
                  id serial PRIMARY KEY,
                  created_at timestamp,
                  mr_id integer,
                  raw_data jsonb,
                  message text
              );`)
          
  }
}
