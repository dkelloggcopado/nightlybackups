public inherited sharing class EggInteg_CheckTaskStatusCalloutInvocable
{
    @InvocableMethod
    (
        label = 'Eggplant Check Task Status'
        description = 'Fetch the status information for a previous scheduled task.'
        callout = true
        category = 'Eggplant DAI Service'
    )
    public static List<CheckTaskStatusOutput> checkTaskStatus(List<CheckTaskStatusInput> taskList)
    {
        if (taskList == null || taskList.isEmpty())
        {
            throw new ScheduleTaskException('A list of Tasks to process is required.');
        }

        CheckTaskStatusInput input = taskList.get(0);
        CheckTaskStatusOutput output = 
            (CheckTaskStatusOutput) 
            JSON.deserialize(EggInteg_CheckTaskStatusCallout.construct().execute(input.access_token, input.task_instance_id), CheckTaskStatusOutput.class);
        return new List<CheckTaskStatusOutput> {output};
    }

    public class CheckTaskStatusInput
    {
        @InvocableVariable
        (
            label = 'Access Token'
            description = 'Bearer token acquired from the login'
            required = true
        )
        public String access_token;

        @InvocableVariable
        (
            label = 'Task Instance ID'
            description = 'Identifier of the execution instance of the task.'
            required = true
        )
        public String task_instance_id;
    }

    public class CheckTaskStatusOutput
    {
        @InvocableVariable
        (
            label = 'Created Date & Time'
            description = 'The current status of the task execution instance.'
        )
        public String created_datetime;
        
        @InvocableVariable
        (
            label = 'Run Status'
            description = 'The current status of the task execution instance.'
        )
        public String runstatus;
        
        @InvocableVariable
        (
            label = 'Test Config Id'
            description = 'The current status of the task execution instance.'
        )
        public String test_config_id;
        
        @InvocableVariable
        (
            label = 'Task Instance Id'
            description = 'The current status of the task execution instance.'
        )
        public String task_instance_id;
        
        @InvocableVariable
        (
            label = 'Updated Date & Time'
            description = 'The current status of the task execution instance.'
        )
        public String updated_datetime;
    }

    public class ScheduleTaskException
        extends Exception
    {
        // Intentionally blank
    }
}