classdef MobileTimer < handle
    
    properties
        
        nTimerInterval = 1;
        hTimer;
        hContext;
        prefix;
        
    end
    
    methods
        
        function [obj] = MobileTimer(context)
            
            if ismac
                obj.prefix = '/usr/local/bin/';
            else
                obj.prefix = '';
            end
            
            obj.hContext = context;
            hTimer = timer();
            hTimer.StartDelay = obj.nTimerInterval;
            hTimer.Period = obj.nTimerInterval;
            hTimer.TimerFcn = @timerCallback;
            hTimer.ExecutionMode = 'fixedRate';
            
            obj.hTimer = hTimer;
            
            start(hTimer);
        
        
%             function [] = start(obj)
% 
%                 start(obj.hTimer);
% 
%             end
% 
%             function [] = stop(obj)
% 
%                 stop(obj.hTimer);
% 
%             end

            function timerCallback(src, event)
                
                sTestDevices = [obj.prefix,'adb devices'];
                [~, sList] = system(sTestDevices);
                
                if (length(splitlines(sList)) < 4)
                    obj.hContext.bIsPhoneConnected = false;
                    obj.hContext.hButton_Reboot.Enable = 'Off';
                    obj.hContext.hButton_Erase.Enable = 'Off';
                    obj.hContext.hButton_Load.Enable = 'Off';
                    obj.hContext.hButton_KillApp.Enable = 'Off';
                else
                    obj.hContext.bIsPhoneConnected = true;
                    obj.hContext.hButton_Reboot.Enable = 'On';
                    obj.hContext.hButton_Erase.Enable = 'On';
                    obj.hContext.hButton_KillApp.Enable = 'On';
                    if obj.hContext.bNewFolder
                        obj.hContext.hButton_Load.Enable = 'On';
                    end
                end


            end
        
        end
        
        
    end
    
    
    
    
end