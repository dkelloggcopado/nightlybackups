public inherited sharing class EggInteg_ScheduleTaskCalloutInvocable
{
    @InvocableMethod
    (
        label = 'Eggplant Schedule Task'
        description = 'Create a task instance and start a test config run.'
        callout = true
        category = 'Eggplant DAI Service'
    )
    public static List<ScheduleTaskOutput> scheduleAndRunTask(List<ScheduleTaskInput> taskList)
    {
        if (taskList == null || taskList.isEmpty())
        {
            throw new ScheduleTaskException('A list of Tasks to process is required.');
        }

        ScheduleTaskInput input = taskList.get(0);
        ScheduleTaskOutput output = new ScheduleTaskOutput();
        output.task_instance_id = EggInteg_ScheduleTaskCallout.construct().execute(input.access_token, input.task_id);
        return new List<ScheduleTaskOutput> {output};
    }

    public class ScheduleTaskInput
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
            label = 'Task ID'
            description = 'Identifier of the test suite to execute.'
            required = true
        )
        public String task_id;
    }

    public class ScheduleTaskOutput
    {
        @InvocableVariable
        (
            label = 'Task Instance ID'
            description = 'The identifier of the running task that was created.'
        )
        public String task_instance_id;
    }

    public class ScheduleTaskException
        extends Exception
    {
        // Intentionally blank
    }
}