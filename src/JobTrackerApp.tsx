import { useEffect, useState } from 'react'
import { supabase } from './api/supabase'
import type { PostgrestError } from '@supabase/supabase-js'

interface JobApplication {
  id: string
  company: string
  status: string
}

export const JobTrackerApp = () => {
  const [applications, setApplications] = useState<JobApplication[]>([])

  useEffect(() => {
    async function getApplications() {
      const {
        data,
        error,
      }: { data: JobApplication[] | null; error: PostgrestError | null } =
        await supabase.from('job_applications').select('company, status')

      if (error) {
        console.error(error)
        return
      }

      setApplications(data ?? [])
    }

    getApplications()
  }, [])

  return (
    <ul>
      {applications.map((application) => (
        <li key={application.id}>
          {application.company} - {application.status}
        </li>
      ))}
    </ul>
  )
}
